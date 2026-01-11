classdef SnakeModel < handle
    
    properties
        gridSize
        state       
        snake       
        direction
        food
        alive = true
    end
    
    methods
        function obj = SnakeModel(gridSize)
            if nargin < 1
                gridSize = [20 20];
            end
            obj.gridSize = gridSize;
            obj.reset();
        end
        
        function reset(obj)
            obj.state = zeros(obj.gridSize);
            center = floor(obj.gridSize / 2);
            
            obj.snake = [ ...
                center;
                center + [0 -1];
                center + [0 -2] ];
            
            obj.direction = [0 1];
            obj.alive = true;
            obj.placeFood();
            obj.updateState();
        end
        
        function step(obj)
            if ~obj.alive
                return;
            end
            
            head = obj.snake(1,:);
            newHead = head + obj.direction;
            
            newHead = [ ...
                mod(newHead(1)-1, obj.gridSize(1)) + 1, ...
                mod(newHead(2)-1, obj.gridSize(2)) + 1 ];
            
            if ismember(newHead, obj.snake, 'rows')
                obj.alive = false;
                return;
            end
            
            obj.snake = [newHead; obj.snake(1:end-1,:)];
            
            if ~isempty(obj.food) && isequal(newHead, obj.food)
                obj.snake = [newHead; obj.snake];
                obj.placeFood();
            end
            
            obj.updateState();
        end
        
        function setDirection(obj, dir)
            % prevent 180-degree turn
            if ~isequal(dir, -obj.direction)
                obj.direction = dir;
            end
        end
    end
    
    methods (Access = private)
        function placeFood(obj)
            occupied = false(obj.gridSize);
            for k = 1:size(obj.snake,1)
                occupied(obj.snake(k,1), obj.snake(k,2)) = true;
            end
            
            free = find(~occupied);
            if isempty(free)
                obj.food = [];
                obj.alive = false;
                return;
            end
            
            idx = free(randi(numel(free)));
            [r, c] = ind2sub(obj.gridSize, idx);
            obj.food = [r c];
        end
        
        function updateState(obj)
            obj.state(:) = 0;
            
            for k = 1:size(obj.snake,1)
                obj.state(obj.snake(k,1), obj.snake(k,2)) = 1;
            end
            
            if ~isempty(obj.food)
                obj.state(obj.food(1), obj.food(2)) = 2;
            end
        end
    end
end
