function [inline, crossline, time] = bsCalcWellBaseInfo(timeLine, X, Y, xId, yId, inId, crossId, timeId)
%% Find the nearest inline, crossline, and time information of given X and Y coordinates
% Programmed by: Bin She (Email: bin.stepbystep@gmail.com)
% Programming dates: Nov 2019
% -------------------------------------------------------------------------
%
% Input 
% timeLine  horizon information, saving x and y
% coordinates, inline and crossline ids, and time information of each trace
% X         the X coordinate of the target trace
% Y         same as X
% xId       which column in timeLine is the X coordinate
% yId       same as X
% inId      which column in timeLine is the inline information
% crossId   same as inId
% timeId    which column in timeLine is the time information
%
% Output
% inline    the inline id of the target trace
% crossline the crossline id of the target trace
% time      the time information of the target trace
% -------------------------------------------------------------------------

%     tic
%     dist = sqrt( (timeLine(:, xId) - X).^2 + (timeLine(:,yId) - Y).^2 );
%     [~, index] = min(dist);
%     toc

    index = find(timeLine(:, xId) == X & timeLine(:, yId) == Y);
    inline = timeLine(index, inId);
    crossline = timeLine(index, crossId);
    time = timeLine(index, timeId);
end