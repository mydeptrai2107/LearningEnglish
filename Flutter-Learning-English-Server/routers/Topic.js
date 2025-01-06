const express = require('express')
const Router = express.Router()

const Controller = require('../controllers/Topic')

Router.get('/library/:username', Controller.get_topics)

Router.get('/getTopic/:topicId', Controller.get_topic_from_id)

Router.get('/public', Controller.get_all_public_topics)

Router.post('/add', Controller.add_topic)

Router.delete('/delete/:topicId', Controller.delete_topic)

Router.patch('/rename/:topicId', Controller.rename_topic)

Router.post('/:topicId/borrow-topic/:username', Controller.add_topic_to_user)

Router.delete('/:topicId/remove-topic/:username', Controller.remove_topic_from_user)

Router.get('/:topicId/words/:username', Controller.get_words_from_topic)

Router.post('/:topicId/add-words/:username', Controller.add_words_to_topic)

Router.delete('/remove-word/:wordId', Controller.remove_word_from_topic)

Router.patch('/adjust-word/:wordId', Controller.adjust_word_in_topic)

Router.patch('/toggle-mark-word/:wordId', Controller.toggle_mark_word_in_topic)

Router.patch('/update-progress-words/', Controller.update_progress_words_in_topic)

module.exports = Router