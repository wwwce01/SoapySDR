// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

namespace SoapySDR
{    
    public class Range
    {
        internal RangeInternal _range = null;

        public Range() => _range = new RangeInternal();

        public Range(double minimum, double maximum, double step = 0.0) => _range = new RangeInternal(minimum, maximum, step);

        internal Range(RangeInternal rangeInternal) => _range = rangeInternal;

        public double Minimum => _range.minimum();

        public double Maximum => _range.maximum();

        public double Step => _range.step();

        // TODO: object overrides
    }
}