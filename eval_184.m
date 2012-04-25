%%Evaluation Script
% Generates all test files required by the rubric for the Spring 2012 ECE
% 184 term project. Generated files are moved to a zip archive for turn-in.

%% Setup
TEAM_NAME = 'EMMA';
test1 = 'demodtest1.wav';
test2 = 'demodtest2.wav';
mtest1 = 'modtest1.jpg';
mtest2 = 'modtest2.jpg';
dogfood = 'modtest3.jpg';

%% Modulator Tests
modulator(mtest1, strcat(TEAM_NAME, '_modtest1.wav'));
modulator(mtest2, strcat(TEAM_NAME, '_modtest2.wav'));
modulator(dogfood, strcat(TEAM_NAME, '_modtest3.wav'));

%% Demodulation Tests
demodulator(test1, strcat(TEAM_NAME, '_demodtest1.jpg'));
demodulator(test2, strcat(TEAM_NAME, '_demodtest2.jpg'));

demodulator(strcat(TEAM_NAME, '_modtest3.wav'), ...
    strcat(TEAM_NAME, '_demodtest3.jpg'));

%% Impairment Tests

%% AWGN
impairment_AWGN(test1, strcat(TEAM_NAME, '_AWGN_M20db.wav'), -20);
impairment_AWGN(test1, strcat(TEAM_NAME, '_AWGN_P10db.wav'), +10);

%% Fade, Echo
impairment_fading(test1, strcat(TEAM_NAME, '_FADE.wav'), .5);
impairment_multipath(test1, strcat(TEAM_NAME, '_ECHO.wav'), 3, 50);

%% Turn in (UNIX)
DONE = 0;

if(DONE && isunix)
    dir = [TEAM_NAME, '_turnin'];
    system(['mkdir ', dir]);
    system(['mv ', TEAM_NAME,'_*test* ./', dir]);
    system(['cp modulator.m ', dir, '/', TEAM_NAME, ...
        '_modulator.m']);
    system(['cp demodulator.m ', dir, '/', TEAM_NAME, ...
        '_demodulator.m']);
    system(['cp impairment_AWGN.m ', dir, '/', TEAM_NAME, ...
        '_impairment_AWGN.m']);
    system(['cp impairment_fading.m ', dir, '/', TEAM_NAME, ...
        '_impairment_fading.m']);
    system(['cp impairment_multipath.m ', dir, '/', TEAM_NAME, ...
        '_impairment_multipath.m']);
    system(['zip -r ', dir, ' ', dir]);
end

