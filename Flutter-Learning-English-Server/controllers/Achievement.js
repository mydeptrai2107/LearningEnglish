const package = require("../middlewares/package.js");
const { default: mongoose } = require('mongoose')
const History = require('../models/History.js')
const Topic = require('../models/Topic.js')
const Achievement = require('../models/Achievement.js')
const Account = require('../models/Account.js')

module.exports.save_history = (req, res) => {
    const { username, topicId, mode, total, correct, duration } = req.body

    if (!mongoose.Types.ObjectId.isValid(topicId)) {
        return res.json(package(1, 'Invalid topic ID', null))
    }

    if (!username || !mode || !total || !duration) {
        return res.json(package(1, 'Please provide full information (username, mode, total, duration)', null))
    }

    const newHistory = new History({
        username, topicId, mode, total, correct, duration
    })

    newHistory.save()
        .then(history => {

            Promise.all([
                (correct === total) ? updateUsersMostCorrect(topicId) : null,
                updateUsersShortestTime(topicId),
                updateUsersMostTimes(topicId)
            ])

            return res.json(package(0, 'Save history successfully', history))
            
        })
        .catch(err => {
            return res.json(package(1, 'Save history failed', null))
        })
}

module.exports.search_achievements_by_category = async  (req, res) => {
    const { topicId, category } = req.params

    if (!mongoose.Types.ObjectId.isValid(topicId)) {
        return res.json(package(1, 'Invalid topic ID', null))
    }

    if (!category) {
        return res.json(package(1, 'Please provide category', null))
    }

    if(category !== 'corrects' && category !== 'duration' && category !== 'times') {
        return res.json(package(1, 'Category of achievement not found', null))
    }

    try {
        const achievements = await Achievement.find({ topicId, category }).sort({ rank: 1 }).exec()

        if (achievements.length === 0) {
            return res.json({ code: 0, message: 'No achievements found', data: [] })
        }

        const topicIds = achievements.map(achievement => achievement.topicId)

        const topics = await Topic.find({ _id: { $in: topicIds } }).exec()
        
        const topicMap = topics.reduce((map, topic) => {
            map[topic._id] = topic
            return map
        }, {})

        const detailsAchievements = achievements.map(achievement => {
            const topic = topicMap[achievement.topicId];
            return {
                ...achievement.toObject(),
                topic: topic,
            }
        })

        return res.json({ code: 0, message: 'Search achievements successfully', data: detailsAchievements })
    } catch (err) {
        return res.json({ code: 1, message: 'Search achievements failed', error: err })
    }
}

module.exports.get_personal_achievements = async (req, res) => {
    const { username } = req.params

    if (!username) {
        return res.json(package(1, 'Please provide username', null))
    }

    try {
        const achievements = await Achievement.find({ username }).exec()

        if (achievements.length === 0) {
            return res.json(package(0, 'No achievements found', []))
        }

        const topicIds = achievements.map(achievement => achievement.topicId)

        const topics = await Topic.find({ _id: { $in: topicIds } }).exec()
        
        const topicMap = topics.reduce((map, topic) => {
            map[topic._id] = topic
            return map
        }, {});

        const enrichedAchievements = achievements.map(achievement => {
            const topic = topicMap[achievement.topicId];
            return {
                ...achievement.toObject(),
                topic: topic,
            };
        });

        return res.json(package(0, 'Search achievements successfully', enrichedAchievements))
    } catch (err) {
        return res.json(package(1, 'Search achievements failed', err))
    }
}

function updateUsersMostCorrect(topicId) {
    History.aggregate([
        { $match: { topicId: new mongoose.Types.ObjectId(topicId) } },
        {
            $group: {
                _id: "$username",
                correct: { $max: "$correct" },
                records: { $push: { correct: "$correct", createAt: "$createAt" } }
            }
        },
        {
            $addFields: {
                createAt: {
                    $reduce: {
                        input: "$records",
                        initialValue: null,
                        in: {
                            $cond: {
                                if: { $eq: ["$$this.correct", "$correct"] },
                                then: "$$this.createAt",
                                else: "$$value"
                            }
                        }
                    }
                }
            }
        },
        { $sort: { correct: -1, createAt: 1 } },
        { $limit: 5 }
    ])
        .then(async results => {
            if (results.length !== 0) {

                var rank = 1
                var promises = []

                for (const result of results) {
                    const promise = Achievement.findOneAndUpdate(
                        { topicId: topicId, category: 'corrects', rank: rank },
                        { $set: { username: result._id, topicId: topicId, category: 'corrects', achievement: result.correct, rank: rank } },
                        { upsert: true, new: true }
                    ).exec()

                    promises.push(promise);
                    rank++;
                }

                Promise.all(promises)
                    .then(achievements => {
                        console.log('All achievements created or updated successfully')
                    })
                    .catch(err => {
                        console.log('Error creating or updating achievements:', err)
                    })
            }

        })
        .catch(err => {
            console.log('Update most correct answers topic failed', err)
        });
}

function updateUsersShortestTime(topicId) {
    History.aggregate([
        {
            $match: {
                topicId: new mongoose.Types.ObjectId(topicId),
                $expr: { $eq: ["$total", "$correct"] }
            }
        },
        {
            $group: {
                _id: "$username",
                duration: { $min: "$duration" },
                records: { $push: "$$ROOT" }
            }
        },
        { $sort: { duration: 1 } },
        { $limit: 5 }
    ])
        .then(async results => {
            if (results.length !== 0) {

                var rank = 1
                var promises = []

                for (const result of results) {
                    const promise = Achievement.findOneAndUpdate(
                        { topicId: topicId, category: 'duration', rank: rank },
                        { $set: { username: result._id, topicId: topicId, category: 'duration', achievement: result.duration, rank: rank } },
                        { upsert: true, new: true }
                    ).exec()

                    promises.push(promise);
                    rank++;
                }

                Promise.all(promises)
                    .then(achievements => {
                        console.log('All achievements created or updated successfully')
                    })
                    .catch(err => {
                        console.log('Error creating or updating achievements:', err)
                    })
            }
        })
        .catch(err => {
            console.log('Update shortest time complete topic failed', err)
        });
}

function updateUsersMostTimes(topicId) {
    History.aggregate([
        { $match: { topicId: new mongoose.Types.ObjectId(topicId) } },
        { $group: { _id: "$username", count: { $sum: 1 }, records: { $push: "$$ROOT" } } },
        { $sort: { count: -1 } },
        { $limit: 5 }
    ])
        .then(async results => {
            if (results.length !== 0) {

                var rank = 1
                var promises = []

                for (const result of results) {
                    const promise = Achievement.findOneAndUpdate(
                        { topicId: topicId, category: 'times', rank: rank },
                        { $set: { username: result._id, topicId: topicId, category: 'times', achievement: result.count, rank: rank } },
                        { upsert: true, new: true }
                    ).exec()

                    promises.push(promise);
                    rank++;
                }

                Promise.all(promises)
                    .then(achievements => {
                        console.log('All achievements created or updated successfully')
                    })
                    .catch(err => {
                        console.log('Error creating or updating achievements:', err)
                    })
            }
        })
        .catch(err => {
            console.log('Update most times study topic failed', err)
        })
}

module.exports.get_achievements_byTopicId = async (req, res) => {
    const { topicId } = req.params

    if (!topicId) {
        return res.json(package(1, 'Please provide topic id', null))
    }

    try {
        const achievements = await Achievement.find({ topicId }).exec()

        if (achievements.length === 0) {
            return res.json(package(0, 'No achievements found', []))
        }

        const topicIds = achievements.map(achievement => achievement.topicId)

        const topics = await Topic.find({ _id: { $in: topicIds } }).exec()
        
        const topicMap = topics.reduce((map, topic) => {
            map[topic._id] = topic
            return map
        }, {});

        const userNames = achievements.map(achievement => achievement.username)
        const users = await Account.find({ username: { $in: userNames } }).exec()
        const userMap = users.reduce((map, user) => {
            map[user.username] = user
            return map
        }, {});

        const enrichedAchievements = achievements.map(achievement => {
            const topic = topicMap[achievement.topicId];
            const user = userMap[achievement.username];
            return {
                ...achievement.toObject(),
                topic: topic,
                user: user,
            };
        });

        return res.json(package(0, 'Search achievements successfully', enrichedAchievements))
    } catch (err) {
        return res.json(package(1, 'Search achievements failed', err))
    }
}