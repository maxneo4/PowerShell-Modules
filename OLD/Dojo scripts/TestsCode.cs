#region $project sql

        [Ignore]
        [TestMethod]
        [TestCategory("IntegrationTest")]
        public void $($Project)Test()
        {
            //given
            CConfiguration source = $project.Instance.Configuration;
            _application = ApplicationFactory.Instance.BuildApplication(new InjectorApplicationIntegrationTestUtility.ApplicationBuilder(source));
           
            CConfiguration secondary = new CConfiguration(EProviderType.MSSqlClient, CommonSecondaryConnectionString);
            CConfiguration target = new CConfiguration(EProviderType.MSSqlClient, CommonTargetConnectionString);
            CConfiguration admon = new CConfiguration(EProviderType.MSSqlClient, CommonAdmonConnectionString);

			UpgraderIntegrationTest.GetDataProvider(admon, "$dbName").ExecuteQuery("$scriptRestore");
			
            RunDeploymentTest(
                admon,
                $project.Instance.Configuration,
                secondary,
                target,
                new Guid("$GuidA"),
                new Guid("$GuidB"),
                new Guid("$GuidC")
        }
		
#endregion

