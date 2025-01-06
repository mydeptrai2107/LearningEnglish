const express = require('express')
const Router = express.Router()

const Controller = require('../controllers/Achievement')

Router.post('/save-history', Controller.save_history)

Router.get('/search-achivements/:topicId/:category', Controller.search_achievements_by_category)

Router.get('/personal-achivements/:username', Controller.get_personal_achievements)

Router.get('/get-achivements/:topicId', Controller.get_achievements_byTopicId)

module.exports = Router