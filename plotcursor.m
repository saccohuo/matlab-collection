function plotcursor(varargin)
%place two cursor on axes to measure value of the plot
% problem to be solved:
% 1. 运行该函数之后，如果修改 axes 的 XLim，会导致 cursor 不工作，需要解决。
% 2. 对于需要一次性对多个 axes 添加 cursor 的情况，暂时没考虑。
% 3. 可以针对 axes property 中的 UIcontextmenu 加点东西，来实现更多功能。
% 4. 对于不连续函数，需要进行一些修正。本不应该显示坐标值。
%
% PLOTCURSOR(y)
% PLOTCURSOR(x,y)
% PLOTCURSOR(x1,y1,x2,y2,...)
% PLOTCURSOR(xycell) include all the {x1,y1,x2,y2,...} in the cell.
% PLOTCURSOR(hAxes,x,y)
% PLOTCURSOR(hAxes,x1,y1,x2,y2,...)
% PLOTCURSOR(hAxes,xycell) include all the {hAxes,x1,y1,x2,y2,...} in the cell.
% PLOTCURSOR(hFig,hAxes,x,y)
% PLOTCURSOR(hFig,hAxes,x1,y1,x2,y2,...)
% PLOTCURSOR(hFig,hAxes,xycell) include all the {hFig,hAxes,x1,y1,x2,y2,...} in the cell.
%
% PROPERTY        VALUE {Default} DESCRIPTION
% hFig: handle of parent figure of axes to be modified
% hAxes: handle of axes to be modified
% x: vector data of x axis in the plot
% y: vector data of y axis in the plot
% -----------------------------------------------------------
% Direction:
% plotcursor(fig2, axes_el_rect, theta_pol, pat_rect(:, idx));
%
%
% Sacco Huo, BIT, Beijing, CHINA.
% shuaike945@gmail.com
% Mastering MATLAB R2016a
% 2016-10-23

%--------------------------------------------------------------------------
% Parse Inputs                                                 Parse Inputs
%--------------------------------------------------------------------------
% disp(nargin);
% return;
nargi = nargin;
if nargi>=2 && isvector(varargin{1}) && ishandle(varargin{1})
    if isvector(varargin{2}) && ishandle(varargin{2})
        hFig = varargin{1};
        hAxes = varargin{2};
    else
        hFig = get(0,'CurrentFigure');
        hAxes = varargin{1};
    end
else
    hFig = get(0,'CurrentFigure');
    hAxes = get(hFig,'CurrentAxes');
end

%--------------------------------------------------------------------------
% Consider input arguments                         Consider input arguments
%--------------------------------------------------------------------------
if nargi==1    % PLOTCURSOR(y) PLOTCURSOR(xycell)
    if isvector(varargin{1})
        y{1} = varargin{1};
        x{1} = 1:length(y);
    elseif iscell(varargin{1})
        if(rem(length(varargin{1}),2) == 0)
            for idx=1:length(varargin{1})/2
                x{idx} = varargin{1}{2*idx-1};
                y{idx} = varargin{1}{2*idx};
            end
        else
            error('xycell 中的参数个数应该是偶数');
            return;
        end
    else
        error('参数类型错误');
        return;
    end
end

if nargi==2    % PLOTCURSOR(x,y) PLOTCURSOR(hAxes,xycell)
    if isvector(varargin{1}) && ishandle(varargin{1}) && ...
            iscell(varargin{2}) % PLOTCURSOR(x,y)
        if(rem(length(varargin{2}),2) == 0)
            for idx=1:length(varargin{2})/2
                x{idx} = varargin{2}{2*idx-1};
                y{idx} = varargin{2}{2*idx};
            end
        else
            error('xycell 中的参数个数应该是偶数');
            return;
        end
    elseif isvector(varargin{1}) && isvector(varargin{2}) % PLOTCURSOR(hAxes,xycell)
        x{1} = varargin{1};
        y{1} = varargin{2};
    else
        error('参数类型错误');
        return;
    end
end

if nargi==3    % PLOTCURSOR(hAxes,x,y) PLOTCURSOR(hFig,hAxes,xycell)
    if isvector(varargin{1}) && ishandle(varargin{1}) && ...
            isvector(varargin{2}) && ishandle(varargin{2}) && ...
            iscell(varargin{3}) % PLOTCURSOR(hFig,hAxes,xycell)
        if(rem(length(varargin{2}),2) == 0)
            for idx=1:length(varargin{2})/2
                x{idx} = varargin{2}{2*idx-1};
                y{idx} = varargin{2}{2*idx};
            end
        else
            error('xycell 中的参数个数应该是偶数');
            return;
        end
    elseif isvector(varargin{1}) && ishandle(varargin{1}) && ...
            isvector(varargin{2}) && isvector(varargin{3}) % PLOTCURSOR(hAxes,x,y)
        x{1} = varargin{2};
        y{1} = varargin{3};
    else
        error('参数类型错误');
        return;
    end
end

if nargi>=4 && rem(nargi,2)==0   % PLOTCURSOR(hFig,hAxes,x,y) PLOTCURSOR(x1,y1,x2,y2,...) PLOTCURSOR(hFig,hAxes,x1,y1,x2,y2,...)
    if isvector(varargin{1}) && ishandle(varargin{1}) && ...
            isvector(varargin{2}) && ishandle(varargin{2})
        if nargi==4
            if isvector(varargin{3}) && isvector(varargin{4}) % PLOTCURSOR(hFig,hAxes,x,y)
                x{1} = varargin{3};
                y{1} = varargin{4};
            else
                error('参数类型错误');
                return;
            end
        else % PLOTCURSOR(hFig,hAxes,x1,y1,x2,y2,...)
            for idx=2:nargi/2
                if isvector(varargin{2*idx-1}) && ...
                        isvector(varargin{2*idx})
                    x{idx-1} = varargin{2*idx-1};
                    y{idx-1} = varargin{2*idx};
                else
                    error('参数类型错误');
                    return;
                end
            end
        end
    else % PLOTCURSOR(x1,y1,x2,y2,...)
        for idx=1:nargi/2
            if isvector(varargin{2*idx-1}) && ...
                    isvector(varargin{2*idx})
                x{idx} = varargin{2*idx-1};
                y{idx} = varargin{2*idx};
            else
                error('参数类型错误');
                return;
            end
        end
    end
end

if nargi>=5 && rem(nargi,2)==1   % PLOTCURSOR(hAxes,x1,y1,x2,y2,...)
    if isvector(varargin{1}) && ishandle(varargin{1})
        for idx=1:(nargi-1)/2
            if isvector(varargin{2*idx}) && ...
                    isvector(varargin{2*idx+1})
                x{idx} = varargin{2*idx};
                y{idx} = varargin{2*idx+1};
            else
                error('参数类型错误');
                return;
            end
        end
    else
        error('参数类型错误');
        return;
    end
end

%--------------------------------------------------------------------------
% Cursors Process                                           Cursors Process
%--------------------------------------------------------------------------
rt = groot;
rt.CurrentFigure = hFig;
rt.CurrentFigure.CurrentAxes = hAxes;

% x = linspace(0,1,100);
% y = sin(2*pi*x);
% plot(x,y,'-k','LineWidth',1);

pp = {};
numCurves = length(x);

for idx=1:numCurves
    pp{idx} = interp1(x{idx},y{idx},'linear','pp');
    f=@(x)ppval(pp{idx},x); % 通过一维线性插值得到交点纵坐标
    f
    fs{idx} = func2str(f);
    htext{idx}=text(zeros(1,2),zeros(1,2),''); % 显示交点的2个文本标签
    set(htext{idx},'Color','red');
    set(htext{idx},'HorizontalAlignment','right')
end

hline=line([1;1]*get(gca,'XLim'),get(gca,'YLim')'*[1,1],...
           'LineWidth',2,'ButtonDownFcn',@drag); % 2条可移动的竖线

set(hline(1),'Color','red');
set(hline(2),'Color','blue');

% set([hline(1),htext(1)],'Color','red')
% set([hline(2),htext(2)],'Color','blue')
% set(htext(1),'HorizontalAlignment','right')

function drag(this,~)
    xlm=get(gca,'XLimMode'); % 保留 x 轴调整模式
    set(gca,'XLimMode','manual') % 解决竖线超出x轴问题

    wbmuf=get(gcbf,{'WindowButtonMotionFcn',...
                    'WindowButtonUpFcn'}); % 保留鼠标移动放开回调
    set(gcbf,'WindowButtonMotionFcn',@move,...
             'WindowButtonUpFcn',@drop); % 设置回调

    function move(~,~)
        cp = get(gca,'CurrentPoint'); % 鼠标当前点
        % 交点坐标 (cx,cy)
        cx=cp(1);
        % cy=[];
        cxlim = get(gca,'XLim');
        cxmin = cxlim(1);
        cxmax = cxlim(2);
        for idx=1:numCurves
            f = str2func(fs{idx});
            cy(idx) = f(cx);
            cymin(idx) = f(cxmin);
            cymax(idx) = f(cxmax);
        end
        % cy=f(cx);
        if cx >= cxmin && cx <= cxmax
            set(this,'XData',[cx,cx]) % 改变竖线水平位置
                                      % 实时显示当前点
            for idx=1:numCurves
                set(htext{idx}(this==hline),'Position',[cx,cy(idx)], ...
                                  'String',sprintf(' %.2f, %.2f ',cx, ...
                                                   cy(idx)));
            end
        elseif cx <= cxmin
            set(this,'XData',[cxmin,cxmin]) % 改变竖线水平位置
            for idx=1:numCurves
                set(htext{idx}(this==hline),'Position',[cxmin,cymin(idx)], ...
                                  'String',sprintf(' %.2f, %.2f ',cxmin, cymin(idx)));
            end
        else
            set(this,'XData',[cxmax,cxmax]) % 改变竖线水平位置
            for idx=1:numCurves
                set(htext{idx}(this==hline),'Position',[cxmax,cymax(idx)], ...
                                  'String',sprintf(' %.2f, %.2f ',cxmax, cymax(idx)));
            end
        end
    end

    function drop(~,~)
        set(gcbf,'WindowButtonMotionFcn',wbmuf{1},...
                 'WindowButtonUpFcn',wbmuf{2}); % 恢复回调设置
        set(gca,'XLimMode',xlm) % 恢复x轴调整模式
    end
end
end