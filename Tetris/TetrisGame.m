classdef TetrisGame < handle
    
    properties
        board           
        cur             
        next            
        
        timerObj
        tick = 0.5      
        
        fig
        ax
        im
        
        isRunning = false
        gameOver = false
        score = 0
    end

    methods
        function obj = TetrisGame(h, w)
            if nargin < 1, h = 20; end
            if nargin < 2, w = 10; end
            
            obj.board = Board(h, w);
            obj.next  = Tetromino.random();
            
            obj.createFigure();
            obj.spawn();
            obj.render();
        end

        function createFigure(obj)
            obj.fig = figure( ...
                'Name', 'Tetris', ...
                'NumberTitle', 'off', ...
                'KeyPressFcn', @(~,evt) obj.onKey(evt), ...
                'CloseRequestFcn', @(src,~) obj.onClose(src));
            
            obj.ax = axes('Parent', obj.fig);
            obj.im = imagesc(obj.ax, obj.board.grid);
            axis(obj.ax, 'equal', 'off');

            
            cmap = [ ...
                0.1 0.1 0.1;   % background
                0   1   1;     % I
                1   1   0;     % O
                0.6 0   1;     % T
                0   1   0;     % S
                1   0   0;     % Z
                0   0   1;     % J
                1   0.5 0];    % L
            
            colormap(obj.ax, cmap);
            caxis(obj.ax, [0 7]);
            title(obj.ax, sprintf('Score: %d', obj.score), 'FontWeight','bold');
        end

        function start(obj)
            if obj.isRunning
                return;
            end
            
            obj.timerObj = timer( ...
                'ExecutionMode', 'fixedSpacing', ...
                'Period', obj.tick, ...
                'TimerFcn', @(~,~) obj.stepDown());
            
            start(obj.timerObj);
            obj.isRunning = true;
        end

        function stop(obj)
            if obj.isRunning && ~isempty(obj.timerObj) && isvalid(obj.timerObj)
                stop(obj.timerObj);
                delete(obj.timerObj);
            end
            obj.isRunning = false;
        end

        function onClose(obj, fig)
            obj.stop();
            if isvalid(fig)
                delete(fig);
            end
        end

        function spawn(obj)
            obj.cur = obj.next;
            obj.cur.rotIndex = 1;
            
            mask = obj.cur.rotations{obj.cur.rotIndex};
            startCol = floor((obj.board.width - size(mask,2)) / 2) + 1;
            obj.cur.pos = [1, startCol];
            
            obj.next = Tetromino.random();
            
            if ~obj.board.isValid(obj.cur, obj.cur.pos, obj.cur.rotIndex)
                obj.gameOver = true;
                obj.stop();
                title(obj.ax, ...
                    sprintf('Game Over! Score: %d  (Press R to restart)', obj.score), ...
                    'Color', [1 0.2 0.2], 'FontWeight','bold');
            end
        end

        function stepDown(obj)
            if obj.gameOver
                return;
            end
            obj.tryMove([1 0]);
        end

        function moved = tryMove(obj, dpos)
            newPos = obj.cur.pos + dpos;
            
            if obj.board.isValid(obj.cur, newPos, obj.cur.rotIndex)
                obj.cur.pos = newPos;
                obj.render();
                moved = true;
            else
                % If we hit something while falling, lock the piece
                if all(dpos == [1 0])
                    obj.board.lock(obj.cur);
                    cleared = obj.board.clearFullLines();
                    
                    if cleared > 0
                        obj.score = obj.score + 100 * cleared^2;
                        title(obj.ax, sprintf('Score: %d', obj.score));
                    end
                    
                    obj.spawn();
                    obj.render();
                end
                moved = false;
            end
        end

        function rotated = tryRotate(obj, dir)
            newIdx = obj.cur.rotatedIndex(dir);
            pos = obj.cur.pos;

            kicks = [ ...
                0  0;
                0 -1; 0  1;
                0 -2; 0  2;
                1  0; -1 0 ];
            
            rotated = false;
            for k = 1:size(kicks,1)
                testPos = pos + kicks(k,:);
                if obj.board.isValid(obj.cur, testPos, newIdx)
                    obj.cur.rotIndex = newIdx;
                    obj.cur.pos = testPos;
                    rotated = true;
                    break;
                end
            end
            
            if rotated
                obj.render();
            end
        end

        function hardDrop(obj)
            while obj.tryMove([1 0])
            end
        end

        function render(obj)
            scene = obj.board.grid;
            
            if ~obj.gameOver
                cells = obj.cur.getCells();
                
                inside = cells(:,1) >= 1 & cells(:,1) <= obj.board.height & ...
                         cells(:,2) >= 1 & cells(:,2) <= obj.board.width;
                cells = cells(inside,:);
                
                idx = sub2ind(size(scene), cells(:,1), cells(:,2));
                scene(idx) = obj.cur.id;
            end
            
            set(obj.im, 'CData', scene);
            drawnow limitrate;
        end

        function onKey(obj, evt)
            if obj.gameOver
                if strcmpi(evt.Key, 'r')
                    obj.reset();
                end
                return;
            end

            switch evt.Key
                case 'leftarrow'
                    obj.tryMove([0 -1]);
                case 'rightarrow'
                    obj.tryMove([0  1]);
                case 'downarrow'
                    obj.tryMove([1  0]);
                case {'uparrow','x'}
                    obj.tryRotate(1);
                case 'z'
                    obj.tryRotate(-1);
                case 'space'
                    obj.hardDrop();
                case 'p'
                    if obj.isRunning
                        obj.stop();
                    else
                        obj.start();
                    end
                case 'r'
                    obj.reset();
            end
        end

        function reset(obj)
            obj.stop();
            obj.board.reset();
            obj.score = 0;
            obj.gameOver = false;
            
            title(obj.ax, sprintf('Score: %d', obj.score), ...
                'Color', [0 0 0], 'FontWeight','bold');
            
            obj.next = Tetromino.random();
            obj.spawn();
            obj.render();
            obj.start();
        end
    end
end
