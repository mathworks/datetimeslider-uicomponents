classdef DatetimeRangeSlider < matlab.ui.componentcontainer.ComponentContainer

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout       matlab.ui.container.GridLayout
        SelectedMaxDate  matlab.ui.control.DatePicker
        EndDateLabel_3   matlab.ui.control.Label
        Slider           matlab.ui.control.RangeSlider
        SelectedMinDate  matlab.ui.control.DatePicker
        EndDateLabel     matlab.ui.control.Label
        EndDate          matlab.ui.control.DatePicker
        EndDateLabel_2   matlab.ui.control.Label
        StartDate        matlab.ui.control.DatePicker
        StartDateLabel   matlab.ui.control.Label
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        DateFormatChanged
        LimitsChanged
        ValueChanged
    end

    properties
        Value datetime = [datetime('today'),datetime('today') + days(29)]; % Current selected date range
        Limits datetime = [datetime('today'),datetime('today') + calmonths(1)];% Allowable date range
        DateFormat char = 'dd-MMM-yyyy'% Format for displaying dates
    end

    methods

        % Set methods for Value and Limits
        function set.Value(comp, value)
            comp.Value = datetime(value,'Format',comp.DateFormat);
            % Update UI components accordingly
            LimitsorValueChanged(comp);
            notify(comp, 'ValueChanged');
        end
        function set.Limits(comp, limits)
            comp.Limits = limits;
            % Update UI components accordingly
            LimitsorValueChanged(comp);
            notify(comp, 'LimitsChanged');
        end

        function set.DateFormat(comp, format)
            comp.DateFormat = format;
            % Update date pickers and tick labels
            UpdateDateFormat(comp);
            notify(comp, 'DateFormatChanged');
        end

        function UpdateSliderValue(comp,event)
            % Check if StartDate is before EndDate
            if comp.StartDate.Value < comp.EndDate.Value
                % Update the slider and other components
                postSetupFcn(comp)
            else
                % Alert the user if StartDate is not before EndDate
                try
                    uialert(ancestor(comp,"Figure"),"Start date must be before End Date","Incorrect Date Range")
                catch ME
                    rethrow(ME);
                end
                % Revert to the previous value if the condition is not met
                event.Source.Value = event.PreviousValue;
            end
        end

        function UpdateSelectedMinDate(comp,event)
            try
                % Calculate the new slider value based on the selected minimum date
                newMinValue = datenum(comp.SelectedMinDate.Value) - datenum(comp.StartDate.Value) + 1;

                % Check if the newMinValue is within the valid range
                if newMinValue >= 1 && newMinValue <= diff(comp.Slider.Limits) + 1
                    comp.Slider.Value(1) = newMinValue;
                else
                    error('Date out of range');
                end

            catch
                % Alert the user if the selected date is outside the allowable range
                % uialert(ancestor(comp,"Figure"), "Date must be within limits", "Outside of Date Range");

                % Revert to the previous value if the condition is not met
                try
                    comp.SelectedMinDate.Value = event.PreviousValue;
                catch
                    comp.SelectedMinDate.Value = comp.StartDate.Value;
                end
            end
        end

        function UpdateSelectedMaxDate(comp,event)
            try
                % Calculate the new slider value based on the selected maximum date
                newMaxValue = datenum(comp.SelectedMaxDate.Value) - datenum(comp.StartDate.Value) + 1;

                % Check if the newMaxValue is within the valid range
                if newMaxValue >= 1 && newMaxValue <= diff(comp.Slider.Limits) + 1
                    comp.Slider.Value(2) = newMaxValue;
                else
                    error('Date out of range');
                end

            catch
                % Alert the user if the selected date is outside the allowable range
                % uialert(ancestor(comp,"Figure"), "Date must be within limits", "Outside of Date Range");

                % Revert to the previous value if the condition is not met
                try
                    comp.SelectedMaxDate.Value = event.PreviousValue;
                catch
                    comp.SelectedMaxDate.Value = comp.StartDate.Value;
                end
            end
        end
    end
    
    methods (Access = private)
        
        function LimitsorValueChanged(comp)
            % Use this function to update the underlying components

            % Limits changed
            [comp.StartDate.Value, comp.EndDate.Value] = deal(comp.Limits(1),comp.Limits(2));
            UpdateSliderValue(comp)

            % % Selected Values changed
            comp.SelectedMinDate.Value = comp.Value(1);
            UpdateSelectedMinDate(comp)
            comp.SelectedMaxDate.Value = comp.Value(2);
            UpdateSelectedMaxDate(comp)
        end
        
        function UpdateDateFormat(comp)
            increment = days(round(days(comp.EndDate.Value-comp.StartDate.Value)/10));
            DatetimeRange = comp.StartDate.Value:increment:comp.EndDate.Value;
            comp.Slider.MajorTickLabels = categorical(datetime(DatetimeRange,"Format",comp.DateFormat));
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function postSetupFcn(comp)
            % initialize properties
            if isnat(comp.SelectedMinDate.Value)
            comp.SelectedMinDate.Value = datetime('today');
            comp.SelectedMaxDate.Value = datetime('today') + days(29);
            comp.StartDate.Value = datetime('today');
            comp.EndDate.Value = datetime('today') + calmonths(1);
            end
                        
            increment = days(round(days(comp.EndDate.Value-comp.StartDate.Value)/10));
            DatetimeRange = comp.StartDate.Value:increment:comp.EndDate.Value;
            comp.Slider.MajorTicks = 1:datenum(increment):length(DatetimeRange)*datenum(increment);
            comp.Slider.MajorTickLabels = categorical(datetime(DatetimeRange,"Format",comp.DateFormat));
            comp.Slider.Limits = [1 length(DatetimeRange)*datenum(increment)-1];
            try
                comp.Slider.Value(1) = datenum(comp.SelectedMinDate.Value)-datenum(comp.StartDate.Value)+1;
            catch
                comp.Slider.Value(1) = comp.Slider.Limits(1);
            end
            try
                comp.Slider.Value(2) = round((datenum(comp.SelectedMaxDate.Value)-datenum(comp.StartDate.Value)))+1;
            catch
                comp.Slider.Value(2) = comp.Slider.Limits(2);
            end

        end

        % Value changed function: EndDate, StartDate
        function LimitDateValueChanged(comp, event)
            UpdateSliderValue(comp,event)
            comp.Limits =[comp.StartDate.Value, comp.EndDate.Value];
        end

        % Value changed function: SelectedMinDate
        function SelectedMinDateValueChanged(comp, event)
            UpdateSelectedMinDate(comp,event)
            comp.Value(1) = comp.SelectedMinDate.Value;
        end

        % Value changed function: SelectedMaxDate
        function SelectedMaxDateValueChanged(comp, event)
            UpdateSelectedMaxDate(comp,event)
            comp.Value(2) = comp.SelectedMaxDate.Value;
        end

        % Value changed function: Slider
        function SliderValueChanged(comp, event)
            % Generate the range of available dates between StartDate and EndDate
            DatetimeRange = comp.StartDate.Value:comp.EndDate.Value;

            % Ensure slider values are integers
            comp.Slider.Value = floor(comp.Slider.Value);

            % Update the selected minimum and maximum dates
            try
                comp.SelectedMinDate.Value = DatetimeRange(comp.Slider.Value(1));
                comp.SelectedMaxDate.Value = DatetimeRange(comp.Slider.Value(2));
                comp.Value = [comp.SelectedMinDate.Value, comp.SelectedMaxDate.Value];
            catch
                % Handle cases where slider values might be out of bounds
                warning('Slider values are out of bounds. Please check the date range.');
                return;
            end
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
           
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 900 116];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'0.1x', 'fit', 'fit', 8, '1x', 'fit', '1x', 'fit', 'fit', 'fit', '0.1x'};
            comp.GridLayout.RowHeight = {22, 22, 22, 18};
            comp.GridLayout.ColumnSpacing = 13.5416666666667;
            comp.GridLayout.RowSpacing = 8;
            comp.GridLayout.Padding = [13.5416666666667 8 13.5416666666667 8];
            comp.GridLayout.BackgroundColor = [1 1 1];

            % Create StartDateLabel
            comp.StartDateLabel = uilabel(comp.GridLayout);
            comp.StartDateLabel.HorizontalAlignment = 'right';
            comp.StartDateLabel.FontWeight = 'bold';
            comp.StartDateLabel.Layout.Row = 3;
            comp.StartDateLabel.Layout.Column = 2;
            comp.StartDateLabel.Text = 'Limit Start Date:';

            % Create StartDate
            comp.StartDate = uidatepicker(comp.GridLayout);
            comp.StartDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @LimitDateValueChanged, true);
            comp.StartDate.FontWeight = 'bold';
            comp.StartDate.Layout.Row = 3;
            comp.StartDate.Layout.Column = 3;

            % Create EndDateLabel_2
            comp.EndDateLabel_2 = uilabel(comp.GridLayout);
            comp.EndDateLabel_2.HorizontalAlignment = 'right';
            comp.EndDateLabel_2.FontWeight = 'bold';
            comp.EndDateLabel_2.Layout.Row = 3;
            comp.EndDateLabel_2.Layout.Column = 9;
            comp.EndDateLabel_2.Text = ' Limit End Date:';

            % Create EndDate
            comp.EndDate = uidatepicker(comp.GridLayout);
            comp.EndDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @LimitDateValueChanged, true);
            comp.EndDate.FontWeight = 'bold';
            comp.EndDate.Layout.Row = 3;
            comp.EndDate.Layout.Column = 10;

            % Create EndDateLabel
            comp.EndDateLabel = uilabel(comp.GridLayout);
            comp.EndDateLabel.HorizontalAlignment = 'right';
            comp.EndDateLabel.FontWeight = 'bold';
            comp.EndDateLabel.Layout.Row = 2;
            comp.EndDateLabel.Layout.Column = 2;
            comp.EndDateLabel.Text = 'Selected Min Date:';

            % Create SelectedMinDate
            comp.SelectedMinDate = uidatepicker(comp.GridLayout);
            comp.SelectedMinDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @SelectedMinDateValueChanged, true);
            comp.SelectedMinDate.FontWeight = 'bold';
            comp.SelectedMinDate.Layout.Row = 2;
            comp.SelectedMinDate.Layout.Column = 3;

            % Create Slider
            comp.Slider = uislider(comp.GridLayout, 'range');
            comp.Slider.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @SliderValueChanged, true);
            comp.Slider.Layout.Row = 2;
            comp.Slider.Layout.Column = [5 7];

            % Create EndDateLabel_3
            comp.EndDateLabel_3 = uilabel(comp.GridLayout);
            comp.EndDateLabel_3.HorizontalAlignment = 'right';
            comp.EndDateLabel_3.FontWeight = 'bold';
            comp.EndDateLabel_3.Layout.Row = 2;
            comp.EndDateLabel_3.Layout.Column = 9;
            comp.EndDateLabel_3.Text = 'Selected Max Date:';

            % Create SelectedMaxDate
            comp.SelectedMaxDate = uidatepicker(comp.GridLayout);
            comp.SelectedMaxDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @SelectedMaxDateValueChanged, true);
            comp.SelectedMaxDate.FontWeight = 'bold';
            comp.SelectedMaxDate.Layout.Row = 2;
            comp.SelectedMaxDate.Layout.Column = 10;
            
            % Execute the startup function
            postSetupFcn(comp)
        end
    end
end