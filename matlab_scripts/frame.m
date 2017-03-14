%make 30ms frames of an audio signal
function [framed] = frame(audioRecording, duration)

    audio = getaudiodata(audioRecording);
    sampleRate = audioRecording.SampleRate;
    totalSamples = audioRecording.TotalSamples;
    
    %number of samples in each frame
    nSamples = round(sampleRate / 1000 * duration);
    
    %number of frames
    nFrames = ceil(length(audio) / nSamples);
    
    %add a zero padding to the end of audio
    audio = [audio ; zeros(nFrames * nSamples - totalSamples, 1)];
    
    %making the framed matrix
    framed = zeros(nSamples, nFrames);
    
%     for i = 1 : nFrames
%         framed(:, i) = audio((i - 1) * nSamples + 1 : i * nSamples);
%     end

    for i = 1 : nSamples : totalSamples
        framed(:, i)
    end
end