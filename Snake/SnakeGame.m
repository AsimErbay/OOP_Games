classdef SnakeGame < handle
    
    properties
        model
        speed = 0.15
        isRunning = false
    end
    
    properties (Access = private)
        fig
        ax
        img
        tmr
    end
    
    methods
        function obj = SnakeGame(gridSize)
            obj.model = SnakeModel(gridSize);
            
            obj.fig = figure( ...
                'Name', 'Snake', ...
                'NumberTitle', 'off', ...
                'Color', 'w', ...
                'KeyPressFcn', @(~,evt)obj.onKey(evt), ...
                'CloseRequestFcn', @(~,~)obj.onClose());
            
            obj.ax = axes(obj.fig);
            axis(obj.ax, 'ij', 'equal');
            axis(obj.ax, [1 gridSize(2) 1 gridSize(1)]);
            obj.ax.Visible = 'off';
            
            colormap(obj.ax, [ ...
                1 1 1;
                0 0.6 0;
                0.9 0 0]);
            caxis(obj.ax, [0 2]);
            
            obj.img = imagesc(obj.ax, obj.model.state);
            title(obj.ax, 'Space = Pause | Esc = Quit');
            
            obj.tmr = timer( ...
                'ExecutionMode', 'fixedRate', ...
                'Period', obj.speed, ...
                'TimerFcn', @(~,~)obj.tick());
            
            start(obj.tmr);
            obj.isRunning = true;
        end
        
        function delete(obj)
            obj.onClose();
        end
    end
    
    methods (Access = private)
        function tick(obj)
            obj.model.step();
            set(obj.img, 'CData', obj.model.state);
            drawnow limitrate;
            
            if ~obj.model.alive
                obj.gameOver();
            end
        end
        
        function onKey(obj, evt)
            switch evt.Key
                case 'uparrow'
                    obj.model.setDirection([-1 0]);
                case 'downarrow'
                    obj.model.setDirection([1 0]);
                case 'leftarrow'
                    obj.model.setDirection([0 -1]);
                case 'rightarrow'
                    obj.model.setDirection([0 1]);
                case 'space'
                    if obj.isRunning
                        stop(obj.tmr);
                        obj.isRunning = false;
                        title(obj.ax, 'Paused | Space to resume');
                    else
                        start(obj.tmr);
                        obj.isRunning = true;
                        title(obj.ax, 'Arrow keys | Space = Pause | Esc = Quit');
                    end
                case 'escape'
                    obj.onClose();
            end
        end
        
        function gameOver(obj)
            stop(obj.tmr);
            obj.isRunning = false;
            title(obj.ax, sprintf('Game Over | Score: %d | R = Restart | Esc = Quit', ...
                size(obj.model.snake,1)));
            set(obj.fig, 'KeyPressFcn', @(~,evt)obj.onKeyGameOver(evt));
        end
        
        function onKeyGameOver(obj, evt)
            switch evt.Key
                case 'r'
                    obj.model.reset();
                    set(obj.fig, 'KeyPressFcn', @(~,evt)obj.onKey(evt));
                    start(obj.tmr);
                    obj.isRunning = true;
                case 'escape'
                    obj.onClose();
            end
        end
        
        function onClose(obj)
            if ~isempty(obj.tmr) && isvalid(obj.tmr)
                stop(obj.tmr);
                delete(obj.tmr);
            end
            if isvalid(obj.fig)
                delete(obj.fig);
            end
        end
    end
end
