Configuration ContosoWebsite
{
  param ($MachineName)

  Node $MachineName
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = “Present”
      Name = “Web-Server”
    }

    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = “Present”
      Name = “Web-Asp-Net45”
    }

     WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }

    	    Script DeployWebPackage
	    {
		    GetScript = {@{Result = "DeployWebPackage"}}
		    TestScript = {
                if((Test-Path "C:\inetpub\wwwroot\Global.asax") -eq $true)
                {
                    return $true
                }
                else
                {
                    return $false
                }
            }
		    SetScript ={
			    [system.io.directory]::CreateDirectory("C:\WebApp")
			    $dest = "C:\WebApp\Site.zip" 
                Remove-Item -path "C:\inetpub\wwwroot" -Force -Recurse -ErrorAction SilentlyContinue
			    Invoke-WebRequest "https://raw.githubusercontent.com/Araffe/ARM-Templates/master/infra-security-lab/ContosoWeb.zip" -OutFile $dest
			    Add-Type -assembly "system.io.compression.filesystem"
			    [io.compression.zipfile]::ExtractToDirectory($dest, "C:\inetpub\wwwroot")
		    }
		    DependsOn  = "[WindowsFeature]IIS"
	    }
  }
} 