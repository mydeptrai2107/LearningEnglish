const { default: mongoose } = require('mongoose')
const Folder = require('../models/Folder')
const Topic = require('../models/Topic')
const FolderTopic = require('../models/FolderTopic')

module.exports.get_folders = (req, res) => {

    const { accountId } = req.params

    if (!mongoose.Types.ObjectId.isValid(accountId)) {
        return res.json({ code: 1, message: 'Invalid account ID' })
    }

    Folder.find({ accountId }).sort({ createAt: -1 })
        .then(listFolder => {
            return res.json({ code: 0, listFolder })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Search folders failed' })
        })
}

module.exports.add_folder = (req, res) => {

    const { accountId } = req.params
    const { folderName } = req.body

    if (!mongoose.Types.ObjectId.isValid(accountId)) {
        return res.json({ code: 1, message: 'Invalid account ID' })
    }

    if (!folderName) {
        return res.json({ code: 1, message: 'Please provide folder name' })
    }

    const newFolder = new Folder({
        folderName, accountId
    })

    newFolder.save()
        .then(folder => {
            return res.json({ code: 0, message: 'Add folder successfully', folder })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Add folder failed' })
        })
}

module.exports.rename_folder = (req, res) => {
    const { folderId } = req.params
    const { folderName } = req.body

    if (!mongoose.Types.ObjectId.isValid(folderId)) {
        return res.json({ code: 1, message: 'Invalid folder ID' })
    }

    if (!folderName) {
        return res.json({ code: 1, message: 'Please provide folder name' })
    }

    Folder.findByIdAndUpdate(folderId, { folderName: folderName }, { new: true })
        .then(updateFolder => {
            if (!updateFolder) {
                return res.json({ code: 1, message: 'Folder not found' })
            }
            return res.json({ code: 0, message: 'Rename folder successfully', updateFolder })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Rename folder failed' })
        })
}

module.exports.delete_folder = (req, res) => {
    const { folderId } = req.params

    if (!mongoose.Types.ObjectId.isValid(folderId)) {
        return res.json({ code: 1, message: 'Invalid folder ID' })
    }

    Folder.findByIdAndDelete(folderId)
        .then(folder => {
            if (!folder) {
                return res.json({ code: 1, message: 'Folder not found' })
            }

            Promise.all([
                FolderTopic.deleteMany({ folderId: folderId })
            ])

            return res.json({ code: 0, message: 'Delete folder successfully', folder })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Delete folder failed' })
        })
}

module.exports.get_topics_from_folder = (req, res) => {

    const { folderId } = req.params

    if (!mongoose.Types.ObjectId.isValid(folderId)) {
        return res.json({ code: 1, message: 'Invalid folder ID' })
    }

    FolderTopic.find({ folderId })
        .then(folderTopics => {

            const topicIds = folderTopics.map(at => at.topicId)

            return Topic.find({ _id: { $in: topicIds } })
        })
        .then(topics => {
            return res.json({ code: 0, topics })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Search topics failed' })
        });
}

module.exports.add_topic_to_folder = (req, res) => {

    const { folderId, topicId } = req.params

    if (!mongoose.Types.ObjectId.isValid(folderId)) {
        return res.json({ code: 1, message: 'Invalid folder ID' })
    }

    if (!mongoose.Types.ObjectId.isValid(topicId)) {
        return res.json({ code: 1, message: 'Invalid topic ID' })
    }

    const newFolderTopic = FolderTopic({
        folderId: folderId,
        topicId: topicId
    })

    newFolderTopic.save()
        .then(folderTopic => {
            return res.json({ code: 0, message: 'Add topic to folder successfully' })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Add topic to folder failed' })
        })
}

module.exports.remove_topic_from_folder = (req, res) => {
    const { folderId, topicId } = req.params

    if (!mongoose.Types.ObjectId.isValid(folderId)) {
        return res.json({ code: 1, message: 'Invalid folder ID' })
    }

    if (!mongoose.Types.ObjectId.isValid(topicId)) {
        return res.json({ code: 1, message: 'Invalid topic ID' })
    }

    FolderTopic.findOneAndDelete({ folderId, topicId })
        .then(folderTopic => {
            if (!folderTopic) {
                return res.json({ code: 1, message: 'Folder does not contain topic' })
            }

            return res.json({ code: 0, message: "Remove topic from folder successfully" })
        })
        .catch(err => {
            return res.json({ code: 1, message: 'Remove topic from folder failed' })
        })
}