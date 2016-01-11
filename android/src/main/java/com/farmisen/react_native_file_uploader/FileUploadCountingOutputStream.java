package com.farmisen.react_native_file_uploader;

import java.io.FilterOutputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * http://stackoverflow.com/questions/16797468/how-to-send-a-multipart-form-data-post-in-android-with-volley
 */


public class FileUploadCountingOutputStream extends FilterOutputStream {
    private final FileUploadProgressListener progListener;
    private long transferred;
    private final String fileRef;
    private long fileLength;

    public FileUploadCountingOutputStream(final OutputStream out, long fileLength,
                                          String fileRef, final FileUploadProgressListener listener) {
        super(out);
        this.fileLength = fileLength;
        this.fileRef = fileRef;
        this.progListener = listener;
        this.transferred = 0;
    }

    public void write(byte[] b, int off, int len) throws IOException {
        out.write(b, off, len);
        this.transferred += len;
        if (progListener != null) {
            this.progListener.transferred(this.fileRef, this.transferred, fileLength);
        }
    }

    public void write(int b) throws IOException {
        out.write(b);
        this.transferred++;
        if (progListener != null) {
            this.progListener.transferred(this.fileRef, this.transferred, fileLength);
        }
    }

    public void writeBytes (String str) throws IOException {
        out.write(str.getBytes());
    }

}
