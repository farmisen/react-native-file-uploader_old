import React, { NativeModules } from 'react-native'

const FileUploader = {
  upload(settings, callback) {
    NativeModules.FileUploader.upload(settings, callback);
  }
};

export default FileUploader
