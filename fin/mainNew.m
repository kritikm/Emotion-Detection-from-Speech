clear all; clc;

emotions = [string('Anger') string('Sadness')];
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

fprintf('Making KNN Classifier\n');
knnClassifier = fitcknn(data, classes, 'NumNeighbors', nNeighbors, 'Standardize', 1);
fprintf('KNN Classifier ready\n');

fprintf('Making SVM Classifier\n');
svmClassifier = fitcsvm(data, classes, 'KernelFunction', 'rbf', 'Standardize', 1);
fprintf('SVM Classifier ready\n');

classifyThis = input('Enter an audio to be classified ', 's');
[speech, speechFs] = audioread(classifyThis);
if(size(speech, 2) > 1)
    speech = speech(:, 1);
end
analysis = mfcc(speech, speechFs, frameDuration, frameShift, preemphasis, @hamming, ...
    [lowerFrequency upperFrequency], nFilterbankChannels, nCepstralCoefficients + 1, cepstralSineLifter);
x = analysis';

% labels = predict(knnClassifier, x);
labels = predict(svmClassifier, x);
results = zeros(size(emotions, 2), 1);

for i = 1 : size(labels, 1)
    index = find(strcmp(labels(i), emotions));
    results(index) = results(index) + 1;
end

results = results ./ size(labels, 1);

for i = 1 : size(results, 1)
    fprintf('Probability of %s is %f\n', emotions(i), results(i));
end