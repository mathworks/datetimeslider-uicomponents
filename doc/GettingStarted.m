%% Getting Started with Datetime Slider UI Components
% Select a date and an interval in synthetic daily observations. Run this
% script to create the figure, then move the slider thumbs to update the
% marker and shaded interval. No input files are required.
%
% Requires MATLAB R2024a or newer. See ../README.md for setup, the component
% reference, and current date-picker and date-range limitations.

%% Add the Components to the MATLAB Path
% Resolve the repository relative to this script so it can be run from any
% current folder.
repositoryFolder = fileparts(fileparts(mfilename('fullpath')));
addpath(repositoryFolder)

%% Create Daily Observations and a Figure
% A 31-day span avoids the current tick-spacing issue at the endpoints.
firstDate = datetime('today');
dateLimits = [firstDate, firstDate + days(31)];
time = firstDate + days(0:31);
observations = sin(2*pi*(0:31)/14) + 0.02*(0:31);

fig = uifigure(Name="Datetime Slider Getting Started", ...
    Position=[100 100 1200 650]);
layout = uigridlayout(fig, [3 1]);
layout.RowHeight = {'1x', 116, 116};

ax = uiaxes(layout);
ax.Layout.Row = 1;
plot(ax, time, observations, '-o')
title(ax, "Select a date and a date interval")
xlabel(ax, "Date")
ylabel(ax, "Synthetic observation")
xlim(ax, dateLimits)
grid(ax, 'on')

%% Configure the Sliders
% Set limits and selected dates before attaching callbacks. Assigning a
% public property invokes its associated callback, including from code.
dateSlider = DatetimeSlider(layout);
dateSlider.Layout.Row = 2;
dateSlider.Limits = dateLimits;
dateSlider.Value = firstDate + days(9);
dateSlider.DateFormat = 'dd-MMM';

rangeSlider = DatetimeRangeSlider(layout);
rangeSlider.Layout.Row = 3;
rangeSlider.Limits = dateLimits;
rangeSlider.Value = firstDate + days([7 20]);
rangeSlider.DateFormat = 'dd-MMM';

%% Connect the Selections to the Plot
% Read datetime values from the callback source. The callback event does not
% carry a separate Value field. Changes take effect when a drag finishes.
hold(ax, 'on')
selectedRegion = xregion(ax, rangeSlider.Value(1), rangeSlider.Value(2));
dateMarker = xline(ax, dateSlider.Value, '--r');
hold(ax, 'off')

dateSlider.ValueChangedFcn = @(src, event) ...
    set(dateMarker, 'Value', src.Value);
rangeSlider.ValueChangedFcn = @(src, event) ...
    set(selectedRegion, 'Value', src.Value);

% Either control can update the displayed axes limits. The advanced example
% app additionally synchronizes the limits between the two controls.
dateSlider.LimitsChangedFcn = @(src, event) xlim(ax, src.Limits);
rangeSlider.LimitsChangedFcn = @(src, event) xlim(ax, src.Limits);

%% Read the Selected Data
% This computes a snapshot of the current interval. Put the same comparison
% in your own ValueChangedFcn to recompute data after an interaction.
selected = time >= rangeSlider.Value(1) & time <= rangeSlider.Value(2);
selectedData = table(time(selected).', observations(selected).', ...
    VariableNames={'Date', 'Observation'});
disp(selectedData)

%% Explore the Figure
% Move a slider thumb to update the marker or region. Close the figure when
% finished, or run delete(fig). To change selections programmatically:
%
% dateSlider.Value = firstDate + days(12);
% rangeSlider.Value = firstDate + days([10 24]);
%
% Current limitation: the single-date component's Current Date picker moves
% its thumb without updating public Value or invoking ValueChangedFcn. Use
% the thumb or assign Value in code for callbacks. The range component's
% selected-date pickers do update Value and invoke ValueChangedFcn.
