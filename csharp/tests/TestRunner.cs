// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using NUnitLite;
using System.Reflection;

internal class TestRunner
{
    static public int RunNUnitTest(string testFixtureName)
    {
        string filename = string.Format(
                                "{0}_{1}.xml",
                                System.DateTime.Now.ToString("yyyyMMdd_HHmmss"),
                                testFixtureName);

        string[] args = new string[]
        {
            string.Format("--test={0}", testFixtureName),
            string.Format("--result={0}", System.IO.Path.Combine(System.IO.Path.GetTempPath(), filename))
        };

        return new AutoRun(Assembly.GetExecutingAssembly()).Execute(args);
    }
}