function run_tictactoe(varargin)


    vsAI = false;
    aiMark = 'O';

    if nargin >= 1
        vsAI = varargin{1};
    end

    if nargin >= 2
        aiMark = varargin{2};
    end

    TicTacToeApp(vsAI, aiMark);
end
