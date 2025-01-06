const mongoose = require('mongoose')
const Schema = mongoose.Schema

const WordSchema = new Schema({
    username: {
        type: String,
        require: true
    },
    topicId: {
        type: Schema.Types.ObjectId,
        ref: 'Topic',
        require: true
    },
    english: {
        type: String,
        require: true
    },
    vietnamese: {
        type: String,
        require: true
    },
    description: String,
    isStarred: {
        type: Boolean,
        default: false
    },
    numberCorrect: {
        type: Number,
        default: 0
    },
    status: {
        type: String,
        enum: ['not learned', 'currently learning', 'mastered'],
        default: 'not learned'
    },
    copyId: {
        type: Schema.Types.ObjectId,
        ref: 'Word'
    }
})

module.exports = mongoose.model('Word', WordSchema)