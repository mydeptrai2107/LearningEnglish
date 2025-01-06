const express = require('express')
const Router = express.Router()

const Controller = require('../controllers/Folder')

Router.get('/:accountId', Controller.get_folders)

Router.post('/:accountId/add', Controller.add_folder)

Router.delete('/delete/:folderId', Controller.delete_folder)

Router.patch('/rename/:folderId', Controller.rename_folder)

Router.get('/:folderId/topics', Controller.get_topics_from_folder)

Router.post('/:folderId/add-topic/:topicId', Controller.add_topic_to_folder)

Router.delete('/:folderId/remove-topic/:topicId', Controller.remove_topic_from_folder)

module.exports = Router