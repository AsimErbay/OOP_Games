classdef Tetromino < handle
    
    properties
        name
        rotations           
        rotIndex = 1
        pos = [1 1]         
        id                 
    end

    methods (Static)
        function t = random()
            pieces = {'I','O','T','S','Z','J','L'};
            t = Tetromino(pieces{randi(numel(pieces))});
        end
    end

    methods
        function obj = Tetromino(name)
            obj.name = upper(name);
            [obj.rotations, obj.id] = Tetromino.getShape(obj.name);
            obj.rotIndex = 1;
            obj.pos = [1 1];
        end

        function cells = getCells(obj, pos, rotIndex)
            if nargin < 2
                pos = obj.pos;
            end
            if nargin < 3
                rotIndex = obj.rotIndex;
            end

            mask = obj.rotations{rotIndex};
            [r, c] = find(mask);
            cells = [r + pos(1) - 1, c + pos(2) - 1];
        end

        function next = rotatedIndex(obj, dir)
            if nargin < 2
                dir = 1;
            end
            n = numel(obj.rotations);
            next = mod(obj.rotIndex - 1 + dir, n) + 1;
        end
    end

    methods (Static)
        function [rots, id] = getShape(name)
            switch upper(name)
                case 'I'
                    id = 1;
                    base = [1 1 1 1];
                    rots = {base; base'};
                    
                case 'O'
                    id = 2;
                    rots = {[1 1; 1 1]};
                    
                case 'T'
                    id = 3;
                    rots = { ...
                        [1 1 1; 0 1 0], ...
                        [0 1; 1 1; 0 1], ...
                        [0 1 0; 1 1 1], ...
                        [1 0; 1 1; 1 0]};
                    
                case 'S'
                    id = 4;
                    rots = { ...
                        [0 1 1; 1 1 0], ...
                        [1 0; 1 1; 0 1]};
                    
                case 'Z'
                    id = 5;
                    rots = { ...
                        [1 1 0; 0 1 1], ...
                        [0 1; 1 1; 1 0]};
                    
                case 'J'
                    id = 6;
                    rots = { ...
                        [1 0 0; 1 1 1], ...
                        [1 1; 1 0; 1 0], ...
                        [1 1 1; 0 0 1], ...
                        [0 1; 0 1; 1 1]};
                    
                case 'L'
                    id = 7;
                    rots = { ...
                        [0 0 1; 1 1 1], ...
                        [1 0; 1 0; 1 1], ...
                        [1 1 1; 1 0 0], ...
                        [1 1; 0 1; 0 1]};
                    
                otherwise
                    error('Unknown tetromino type: %s', name);
            end
            for i = 1:numel(rots)
                rots{i} = rots{i} ~= 0;
            end
        end
    end
end
