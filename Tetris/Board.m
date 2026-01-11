classdef Board < handle
    
    properties
        height
        width
        grid
    end

    methods
        function obj = Board(h, w)
            if nargin < 1, h = 20; end
            if nargin < 2, w = 10; end
            
            obj.height = h;
            obj.width  = w;
            obj.grid   = zeros(h, w, 'uint8');
        end

        function inside = isInside(obj, cells)
            inside = all( ...
                cells(:,1) >= 1 & cells(:,1) <= obj.height & ...
                cells(:,2) >= 1 & cells(:,2) <= obj.width);
        end

        function free = isFree(obj, cells)
            idx = sub2ind(size(obj.grid), cells(:,1), cells(:,2));
            free = all(obj.grid(idx) == 0);
        end

        function ok = isValid(obj, piece, pos, rotIndex)
            cells = piece.getCells(pos, rotIndex);
            ok = obj.isInside(cells) && obj.isFree(cells);
        end

        function lock(obj, piece)
            cells = piece.getCells();
            idx = sub2ind(size(obj.grid), cells(:,1), cells(:,2));
            obj.grid(idx) = piece.id;
        end

        function cleared = clearFullLines(obj)
            fullRows = all(obj.grid ~= 0, 2);
            cleared = sum(fullRows);
            
            if cleared > 0
                remaining = obj.grid(~fullRows, :);
                obj.grid(:) = 0;
                obj.grid(end-size(remaining,1)+1:end, :) = remaining;
            end
        end

        function reset(obj)
            obj.grid(:) = 0;
        end
    end
end
