emotions = [string('Anger') string('Sadness') string('Elation') string('Happiness')];
nNeighbors = 3;
frameDuration = 20;
frameShift = 10;
preemphasis = 0.97;
nFilterbankChannels = 20;
nCepstralCoefficients = 12;
cepstralSineLifter = 22;
lowerFrequency = 300;
upperFrequency = 3700;
data = double.empty;
classes = cell(0);

for i = 1 : size(emotions, 2)
    toLearn = emotions(i);
    fprintf('Learning %s\n', toLearn);

    learningDir = dir([char(toLearn), '\*.wav']);
    nFiles = length(learningDir(not([learningDir.isdir])));
       
    for j = 1 : nFiles

        [speech, fs] = audioread([char(toLearn) '/' char(lower(toLearn)) int2str(j) '.wav']);
        
        analysis = mfcc(speech, fs, frameDuration, frameShift, preemphasis, @hamming,...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);

        data = [data; analysis'];
        classes = [classes; repmat(cellstr(toLearn), size(analysis, 2), 1)];
           
    end
    
    fprintf('I now know what %s sounds like\n', toLearn);
end

classifier = input('Which classification model do you want to you?\n1.KNN Classifier\n2.Multi-SVM\n');

if classifier == 1
    fprintf('Preparing KNN Classifier\n');
    classificationModel = fitcknn(data, classes, 'Standardize', 1);
    fprintf('KNN Classifier Ready\n');
else
    fprintf('Preparing Multi-SVM Classifier.\n');
    classificationModel = fitcecoc(data, classes);
    fprintf('Multi-SVM Classifier Ready\n');
end

more = 'y';
while(more == 'y' || more == 'Y')
    classifyThis = input('Enter an audio to be classified ', 's');
    [speech, speechFs] = audioread(classifyThis);
    if(size(speech, 2) > 1)
        speech = speech(:, 1);
    end
    analysis = mfcc(speech, speechFs, frameDuration, frameShift, preemphasis, @hamming, ...
        [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
    x = analysis';

    % labels = predict(knnClassifier, x);
    labels = predict(classificationModel, x);

    results = zeros(size(emotions, 2), 1);

    for i = 1 : size(labels, 1)
        index = find(strcmp(labels(i), emotions));
        results(index) = results(index) + 1;
    end

    results = results ./ size(labels, 1);

    % for i = 1 : size(results, 1)
    %     fprintf('Probability of %s is %f\n', emotions(i), results(i));
    % end

    [maxWell, maxPlace] = max(results);

    fprintf('Classifying as %s with a confidence of %f\n', emotions(maxPlace), maxWell);
    
    more = input('Test on more data?(y/n) ', 's');
end