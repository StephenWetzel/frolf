%This functions will take a matrix called score, and the number of players
%num, and then check to see which player has the highest score in column 11
%of the matrix.  It then prints a message.

function checkWinner(score, num, handles)

winner = 1; %default to player one
lowScore = 10000; %scores should always be lower than this

%Lower scores are better
for ii = 1:num
    if score{ii,11} < lowScore %does player have a lower (better) score
        winner = ii; %this is the winner so far
        lowScore = score{ii, 11}; %best score so far
    end
end

handles.mbox = msgbox(sprintf('%s wins with a score of %d!', score{winner,1}, score{winner,11}), 'Winner!'); 
uiwait(handles.mbox);


