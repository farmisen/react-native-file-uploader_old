package com.farmisen.react_native_file_uploader;

/**
 * http://stackoverflow.com/questions/16797468/how-to-send-a-multipart-form-data-post-in-android-with-volley
 */
public interface FileUploadProgressListener {
    void transferred(String fileRef, long transferred, long total);
}
