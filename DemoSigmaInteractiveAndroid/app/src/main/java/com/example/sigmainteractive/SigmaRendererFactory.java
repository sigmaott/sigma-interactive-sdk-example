package com.example.sigmainteractive;

import android.content.Context;
import android.os.Looper;

import androidx.annotation.Nullable;

import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.Renderer;
import com.google.android.exoplayer2.metadata.Metadata;
import com.google.android.exoplayer2.metadata.MetadataDecoder;
import com.google.android.exoplayer2.metadata.MetadataDecoderFactory;
import com.google.android.exoplayer2.metadata.MetadataInputBuffer;
import com.google.android.exoplayer2.metadata.MetadataOutput;
import com.google.android.exoplayer2.metadata.MetadataRenderer;
import com.google.android.exoplayer2.metadata.emsg.EventMessageDecoder;
import com.google.android.exoplayer2.metadata.id3.Id3Decoder;
import com.google.android.exoplayer2.metadata.scte35.SpliceInfoDecoder;
import com.google.android.exoplayer2.util.MimeTypes;
import java.nio.ByteBuffer;
import java.util.ArrayList;

public class SigmaRendererFactory extends DefaultRenderersFactory {

    public interface Id3ParsedListener {

        void onId3Parsed(Metadata metadata);
    }

    private Id3ParsedListener mListener;

    public SigmaRendererFactory(Context context, Id3ParsedListener listener) {
        super(context);
        mListener = listener;
    }

    @Override
    protected void buildMetadataRenderers(
            Context context,
            MetadataOutput output,
            Looper outputLooper,
            @ExtensionRendererMode int extensionRendererMode,
            ArrayList<Renderer> out) {
        out.add(new MetadataRenderer(output, outputLooper, new SigmaMetadataDecoderFactory(mListener)));
    }

    public static class SigmaMetadataDecoderFactory implements MetadataDecoderFactory {
        private Id3ParsedListener mListener;
        public SigmaMetadataDecoderFactory(Id3ParsedListener listener){
            mListener = listener;
        }
        @Override
        public boolean supportsFormat(Format format) {
            @Nullable String mimeType = format.sampleMimeType;
            return MimeTypes.APPLICATION_ID3.equals(mimeType)
                    || MimeTypes.APPLICATION_EMSG.equals(mimeType)
                    || MimeTypes.APPLICATION_SCTE35.equals(mimeType);
        }

        @Override
        public MetadataDecoder createDecoder(Format format) {
            @Nullable String mimeType = format.sampleMimeType;
            if (mimeType != null) {
                switch (mimeType) {
                    case MimeTypes.APPLICATION_ID3:
                        return new SigmaId3Proxy(mListener);
                    case MimeTypes.APPLICATION_EMSG:
                        return new EventMessageDecoder();
                    case MimeTypes.APPLICATION_SCTE35:
                        return new SpliceInfoDecoder();
                    default:
                        break;
                }
            }
            throw new IllegalArgumentException(
                    "Attempted to create decoder for unsupported MIME type: " + mimeType);
        }
    }

    public static class SigmaId3Proxy implements MetadataDecoder {

        private Id3Decoder mInternal = new Id3Decoder();
        private Id3ParsedListener mListener;
        public SigmaId3Proxy(Id3ParsedListener listener){
            mListener = listener;
        }

        @Override
        public Metadata decode(MetadataInputBuffer inputBuffer) {
            Metadata result = mInternal.decode(inputBuffer);
            if (result != null && mListener != null) {
                mListener.onId3Parsed(result);
            }
            return result;
        }
    }
}

