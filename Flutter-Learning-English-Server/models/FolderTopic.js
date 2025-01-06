const mongoose = require('mongoose')
const Schema = mongoose.Schema

const FolderTopicSchema = new Schema({
    folderId: {
        type: Schema.Types.ObjectId,
        ref: 'Folder',
        require: true
    },
    topicId: {
        type: Schema.Types.ObjectId,
        ref: 'Topic',
        require: true
    },
})

module.exports = mongoose.model('FolderTopic', FolderTopicSchema)