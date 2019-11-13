function result = bsButtLowPassFilter(data, Wn)

    if Wn >= 1 || Wn <= 0.02
        result = data;
    else
        [b, a] = butter(10, Wn, 'low');
        result = filtfilt(b, a, data);
    end
end