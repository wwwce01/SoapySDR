// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using NUnitLite;
using System.Reflection;

internal class TestRunner
{
    public static int RunNUnitTest(string testFixtureName)
    {
        string[] args = new string[]
        {
            string.Format("--test={0}", testFixtureName),
            "--noresult"
        };

        return new AutoRun(Assembly.GetExecutingAssembly()).Execute(args);
    }
}