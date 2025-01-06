const mongoose = require('mongoose')
const Schema = mongoose.Schema
const moment = require('moment')

const AchievementSchema = new Schema({
    username: {
        type: String,
        require: true
    },
    topicId: {
        type: Schema.Types.ObjectId,
        ref: 'Topic',
        require: true
    },
    category: {
        type: String,
        enum: ['corrects', 'duration', 'times'],
        require: true
    },
    achievement: {
        type: String,
        require: true
    },
    rank: {
        type: Number,
        require: true
    },
    createAt: {
        type: String,
        default: moment(Date.now()).format('YYYY-MM-DDTHH-mm-ss')
    }
})

module.exports = mongoose.model('Achievement', AchievementSchema)