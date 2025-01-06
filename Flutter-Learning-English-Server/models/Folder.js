const mongoose = require('mongoose')
const Schema = mongoose.Schema
const moment = require('moment');

const FolderSchema = new Schema({
    folderName: {
        type: String,
        require: true
    },
    accountId: {
        type: Schema.Types.ObjectId,
        ref: 'Account',
        require: true
    },
    createAt: {
        type: String,
        default: moment(Date.now()).format('YYYY-MM-DDTHH-mm-ss')
    }
})

module.exports = mongoose.model('Folder', FolderSchema)