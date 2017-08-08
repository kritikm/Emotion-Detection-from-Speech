nNeighbors = 3;
if(exist('learnt', 'file') == 0)
    fprintf('First run\n');
   
    frameDuration = 20;
    frameShift = 10;
    preemphasis = 0.97;
    nFilterbankChannels = 20;
    nCepstralCoefficients = 12;
    cepstralSineLifter = 22;
    lowerFrequency = 300;
    upperFrequency = 3700;
    
    fprintf('Learning hot anger\n');
    [angrySpeech, angerFs] = audioread('Anger/hotangermontage.wav');
    
    angerMFCC = mfcc(angrySpeech, angerFs, frameDuration, frameShift, preemphasis, @hamming,...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    
    data = angerMFCC';
    
    classes = repmat(cellstr('hot anger'), size(angerMFCC', 1), 1);
    
    fprintf('I now know what hot anger sounds like\n');    
    
    fprintf('Learning cold anger\n');
    
    [angerSpeech, angerFs] = audioread('Anger/coldangermontage.wav');
    angerMFCC = mfcc(angerSpeech, angerFs, frameDuration, frameShift, preemphasis, @hamming, ...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    
    data = [data; angerMFCC'];
    
    classes = [classes; repmat(cellstr('cold anger'), size(angerMFCC', 1), 1)];

    fprintf('I now know what cold anger sounds like\n');    
    
    fprintf('Learning sadness\n');
    
    [sadSpeech, sadFs] = audioread('Sadness/sadmontage.wav');
    sadMFCC = mfcc(sadSpeech, sadFs, frameDuration, frameShift, preemphasis, @hamming, ...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    
    data = [data; sadMFCC'];
    
    classes = [classes; repmat(cellstr('sadness'), size(sadMFCC', 1), 1)];
    fprintf('I now know what sadness sounds like\n');
    
    fprintf('Creating classifier\n');
    
    emotionClassifier = fitcknn(data, classes, 'NumNeighbors', nNeighbors, 'Standardize', 1);
    
    fprintf('Classifier ready.\n');
    
    classifyThis = input('Enter an audio to be classified ', 's');
    
    [speech, speechFs] = audioread(classifyThis);
    
    if(size(speech, 2) > 1)
        speech = speech(:, 1);
    end
    
    speechMFCC = mfcc(speech, speechFs, frameDuration, frameShift, preemphasis, @hamming, ...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    x = speechMFCC';
    
    label = predict(emotionClassifier, x);
        
    sadness = 0;
    hotAnger = 0;
    coldAnger = 0;
    
    for i = 1 : size(label, 1)
        if (strcmp(label{i}, 'sadness') == 1)
            sadness = sadness + 1;
        elseif (strcmp(label{i}, 'hot anger') == 1)
            hotAnger = hotAnger + 1;
        elseif (strcmp(label{i}, 'cold anger') == 1)
            coldAnger = coldAnger + 1;
        end             
    end
    
    total = size(label, 1);
    fprintf('Sadness %f\nCold Anger %f\nHot Anger %f\n', sadness / total, coldAnger / total, hotAnger / total);
    
end