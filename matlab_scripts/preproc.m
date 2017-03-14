recording = record(2000);
fs = recording.SampleRate;
frameDuration = 0.025;
frameStep = 0.01;
frames = frame_sig(recording, frameDuration * fs, frameStep * fs, @hamming);
% deframed = deframe_sig(frames, recording.TotalSamples, frameDuration * fs, frameStep * fs, @hamming);
% soundsc(deframed, fs);
framesFFT = fft(frames, 512);
powerSpectrum = abs(framesFFT) .^ 2;

numberOfFilters = 40;
frequencyLimits = [300 8000];

% filterBank = trifbank(40, , frequencyLimits, fs);