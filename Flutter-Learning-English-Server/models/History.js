const mongoose = require('mongoose')
const Schema = mongoose.Schema
const moment = require('moment')

const HistorySchema = new Schema({
    username: {
        type: String,
        require: true
    },
    topicId: {
        type: Schema.Types.ObjectId,
        ref: 'Topic',
        require: true
    },
    mode: {
        type: String,
        enum: ['flashcard', 'quiz', 'type'],
        require: true
    },
    total: {
        type: Number,
        require: true
    },
    correct: {
        type: Number,
        default: 0
    },
    duration: {
        type: Number, // seconds
        required: true
    },
    createAt: {
        type: String,
        default: moment(Date.now()).format('YYYY-MM-DDTHH-mm-ss')
    }
})

module.exports = mongoose.model('History', HistorySchema)