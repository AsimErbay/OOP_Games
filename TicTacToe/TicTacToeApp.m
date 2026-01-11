classdef TicTacToeApp < handle
    
    properties (Access = private)
        fig
        layout
        buttons          
        statusLabel
        resetBtn
        
        board
        currentMark
        gameActive
        
        vsAI
        ai
        aiMark
    end
    
    methods
        function obj = TicTacToeApp(vsAI, aiMark)
            if nargin < 1, vsAI = false; end
            if nargin < 2, aiMark = 'O'; end
            
            % Game state
            obj.board = Board();
            obj.currentMark = 'X';
            obj.gameActive = true;
            
            obj.vsAI = vsAI;
            obj.aiMark = aiMark;
            
            if vsAI
                obj.ai = AIPlayer(aiMark);
            else
                obj.ai = [];
            end
            
            % UI
            obj.createUI();
            obj.updateStatus();
            
            % AI can start
            if obj.vsAI && obj.currentMark == obj.aiMark
                obj.playAIMove();
            end
        end
    end
    
    methods (Access = private)
        function createUI(obj)
            obj.fig = uifigure( ...
                'Name', 'Tic Tac Toe', ...
                'Position', [100 100 360 440], ...
                'Resize', 'off');
            
            obj.layout = uigridlayout(obj.fig, [4 3]);
            obj.layout.RowHeight = {100,100,100,'fit'};
            obj.layout.ColumnWidth = {100,100,100};
            obj.layout.Padding = [10 10 10 10];
            obj.layout.RowSpacing = 8;
            obj.layout.ColumnSpacing = 8;
            
            obj.buttons = gobjects(3,3);
            for r = 1:3
                for c = 1:3
                    b = uibutton(obj.layout, 'push');
                    b.Text = ' ';
                    b.FontSize = 28;
                    b.FontWeight = 'bold';
                    b.Layout.Row = r;
                    b.Layout.Column = c;
                    b.Tag = sprintf('r%dc%d', r, c);
                    b.ButtonPushedFcn = @(src,~) obj.cellClicked(src);
                    obj.buttons(r,c) = b;
                end
            end
            
            
            obj.statusLabel = uilabel(obj.layout);
            obj.statusLabel.Text = 'Player X turn';
            obj.statusLabel.FontSize = 16;
            obj.statusLabel.FontWeight = 'bold';
            obj.statusLabel.Layout.Row = 4;
            obj.statusLabel.Layout.Column = [1 2];
            
            
            obj.resetBtn = uibutton(obj.layout, 'push');
            obj.resetBtn.Text = 'Reset';
            obj.resetBtn.FontSize = 14;
            obj.resetBtn.Layout.Row = 4;
            obj.resetBtn.Layout.Column = 3;
            obj.resetBtn.ButtonPushedFcn = @(~,~) obj.resetGame();
        end
        
        function cellClicked(obj, src)
            if ~obj.gameActive
                return;
            end
            
            [r, c] = obj.readButtonTag(src.Tag);
            
            if ~obj.board.isEmpty(r, c)
                return;
            end
            
            obj.makeMove(r, c, obj.currentMark);
            obj.playAIMove();
        end
        
        function playAIMove(obj)
            if obj.vsAI && obj.gameActive && obj.currentMark == obj.aiMark
                drawnow;
                move = obj.ai.chooseMove(obj.board);
                obj.makeMove(move(1), move(2), obj.currentMark);
            end
        end
        
        function makeMove(obj, r, c, mark)
            if ~obj.board.placeMark(r, c, mark)
                return;
            end
            
            obj.buttons(r,c).Text = mark;
            obj.buttons(r,c).Enable = 'off';
            
            winner = obj.board.getWinner();
            if winner ~= ' '
                obj.endGame(sprintf('Player %s wins!', winner));
                return;
            end
            
            if obj.board.isFull()
                obj.endGame('Draw!');
                return;
            end
            
            obj.currentMark = obj.otherPlayer(mark);
            obj.updateStatus();
        end
        
        function updateStatus(obj)
            if obj.gameActive
                obj.statusLabel.Text = sprintf('Player %s turn', obj.currentMark);
            end
        end
        
        function endGame(obj, text)
            obj.gameActive = false;
            obj.statusLabel.Text = text;
            
            for r = 1:3
                for c = 1:3
                    if obj.board.isEmpty(r,c)
                        obj.buttons(r,c).Enable = 'off';
                    end
                end
            end
        end
        
        function resetGame(obj)
            obj.board.reset();
            obj.currentMark = 'X';
            obj.gameActive = true;
            
            for r = 1:3
                for c = 1:3
                    obj.buttons(r,c).Text = ' ';
                    obj.buttons(r,c).Enable = 'on';
                end
            end
            
            obj.updateStatus();
            
            if obj.vsAI && obj.currentMark == obj.aiMark
                obj.playAIMove();
            end
        end
        
        function [r, c] = readButtonTag(~, tag)
            vals = sscanf(tag, 'r%dc%d');
            r = vals(1);
            c = vals(2);
        end
        
        function mark = otherPlayer(~, mark)
            if mark == 'X'
                mark = 'O';
            else
                mark = 'X';
            end
        end
    end
end
