nNeighbors = 5;
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
    
    fprintf('Learning anger\n');
    [angrySpeech, angerFs] = audioread('Anger/angermontage.wav');
    
    angerMFCC = mfcc(angrySpeech, angerFs, frameDuration, frameShift, preemphasis, @hamming,...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    
    data = angerMFCC';
    
    classes = repmat(cellstr('angry'), size(angerMFCC', 1), 1);
    
    fprintf('I now know what anger sounds like\n');    
    
    fprintf('Learning sadness\n');
    [sadSpeech, sadFs] = audioread('Sadness/sadmontage.wav');
    sadMFCC = mfcc(sadSpeech, sadFs, frameDuration, frameShift, preemphasis, @hamming, ...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    
    data = [data; sadMFCC'];
    
    classes = [classes; repmat(cellstr('sad'), size(sadMFCC', 1), 1)];
    fprintf('I now know what sadness sounds like\n');
    
    fprintf('Creating classifier\n');
    
    emotionClassifier = fitcknn(data, classes, 'NumNeighbors', nNeighbors, 'Standardize', 1);
    
    fprintf('Classifier ready.\n');
    
    classifyThis = input('Enter an audio to be classified ', 's');
    
    [speech, speechFs] = audioread(classifyThis);
    
    if(size(speech, 2) > 1)
        speech = speech(:, 2);
    end
    
    speechMFCC = mfcc(speech, speechFs, frameDuration, frameShift, preemphasis, @hamming, ...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    x = speechMFCC';
    
    label = predict(emotionClassifier, x);
        
    sad = 0;
    angry = 0;
    
    for i = 1 : size(label, 1)
        if (strcmp(label{i}, 'sad') == 1)
            sad = sad + 1;
        elseif (strcmp(label{i}, 'angry') == 1)
            angry = angry + 1;
        end             
    end
    
    fprintf('Sad: %f\tAngry: %f\n', sad / (sad + angry), angry / (sad + angry));
    
end