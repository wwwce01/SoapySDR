// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using NUnit.Framework;

[TestFixture]
public class TestBuildInfo
{
    [Test]
    public void Test_BuildInfoStrings()
    {
        Assert.IsNotEmpty(SoapySDR.BuildInfo.ABIVersion);
        Assert.IsNotEmpty(SoapySDR.BuildInfo.APIVersion);
        Assert.IsNotEmpty(SoapySDR.BuildInfo.LibVersion);
    }
}