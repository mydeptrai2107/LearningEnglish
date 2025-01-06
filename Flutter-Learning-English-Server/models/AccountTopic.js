const mongoose = require('mongoose')
const Schema = mongoose.Schema

const AccountTopicSchema = new Schema({
    username: {
        type: String,
        require: true
    },
    topicId: {
        type: Schema.Types.ObjectId,
        ref: 'Topic',
        require: true
    },
})

module.exports = mongoose.model('AccountTopic', AccountTopicSchema)