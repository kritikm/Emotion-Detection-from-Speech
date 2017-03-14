%duration is in milliseconds
function[recording] = record(duration)
    recording = audiorecorder;
    disp('start speaking');
    recordblocking(recording, duration / 1000);
    disp('end of recording');
end