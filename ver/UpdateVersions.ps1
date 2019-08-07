# ----------------
# Script arguments
# ----------------
param(
	[switch]$useEnvBuild
)

# -----------
# Definitions
# -----------
function UpdateAssemblyInfoVersion(
	[string]$assemblyInfoPath,
	[string]$version,
	[decimal]$build)
{
  Write-Output "Updating file: $assemblyInfoPath"

	$content = Get-Content $assemblyInfoPath -Raw -Encoding UTF8

	$content = [System.Text.RegularExpressions.Regex]::Replace(
		$content,
		'\[assembly\: AssemblyVersion\("\d+\.\d+\.\d+\.\d+"\)\]',
		"[assembly: AssemblyVersion(""$version.$build"")]",
    [System.Text.RegularExpressions.RegexOptions]::MultiLine)

	$content = [System.Text.RegularExpressions.Regex]::Replace(
		$content,
		'\[assembly\: AssemblyFileVersion\("\d+\.\d+\.\d+\.\d+"\)\]',
		"[assembly: AssemblyFileVersion(""$version.$build"")]",
    [System.Text.RegularExpressions.RegexOptions]::MultiLine)

	Set-Content -Path $assemblyInfoPath -Value $content -Encoding UTF8 -NoNewline
}


function UpdateCsProj(
  [string]$csprojPath,
  [string]$version,
  [decimal]$build
)
{
  Write-Output "Updating file: $csprojPath"
	$content = Get-Content $csprojPath -Raw -Encoding UTF8

	$content = [System.Text.RegularExpressions.Regex]::Replace(
		$content,
    '<FileVersion>\d+\.\d+\.\d+\.\d+</FileVersion>',
    "<FileVersion>$version.$build</FileVersion>",
    [System.Text.RegularExpressions.RegexOptions]::MultiLine)

	$content = [System.Text.RegularExpressions.Regex]::Replace(
		$content,
    '<AssemblyVersion>\d+\.\d+\.\d+\.\d+</AssemblyVersion>',
    "<AssemblyVersion>$version.$build</AssemblyVersion>",
    [System.Text.RegularExpressions.RegexOptions]::MultiLine)

	$content = [System.Text.RegularExpressions.Regex]::Replace(
		$content,
    '<Version>\d+\.\d+\.\d+\.\d+</Version>',
    "<Version>$version.$build</Version>",
    [System.Text.RegularExpressions.RegexOptions]::MultiLine)

	Set-Content -Path $csprojPath -Value $content -Encoding UTF8 -NoNewline
}	

function UpdateProducts($srcDirPath, $products, $build)
{
	Write-Output $products

	foreach ($product in $products)
	{
		Write-Output "Processing product '$($product.Product)'..."

		foreach ($project in $product.Projects)
		{
			Write-Output "Writing project version: $project --> $($product.Version).$build"
			$csprojPath = [IO.Path]::Combine($srcDirPath, $project, "$project.csproj")
			$assemblyInfoPath = [IO.Path]::Combine($srcDirPath, $project, 'Properties', 'AssemblyInfo.cs')
	
			if (Test-Path $assemblyInfoPath)
			{
				UpdateAssemblyInfoVersion $assemblyInfoPath $product.Version $build
			}
			else
			{
				UpdateCsProj $csprojPath $product.Version $build
			}
		}

		Write-Output ""
	}
}

$scriptDirPath = Split-Path $script:MyInvocation.MyCommand.Path

$srcDirPath0 = [IO.Path]::Combine($scriptDirPath, '..', 'src')
$srcDirPath = $(resolve-path $srcDirPath0).Path

$buildFilePath = [IO.Path]::Combine($scriptDirPath, 'build')

$build = 0

if (Test-Path $buildFilePath)
{
	$build = [System.Decimal]::Parse($(Get-Content $buildFilePath))
}

if ($useEnvBuild)
{
  Write-Output "Using build number from environment variable 'CurrentBuildId'"
	if (Test-Path 'env:CurrentBuildId')
	{
		$build = [System.Decimal]::Parse($env:CurrentBuildId)
	}
}

Write-Output "Build #: $build";


Write-Output "Updating this repository products"
$productsJsonPath = [IO.Path]::Combine($scriptDirPath, 'products.json')
$products = Get-Content $productsJsonPath | ConvertFrom-Json
UpdateProducts $srcDirPath $products $build

<#
Write-Output "Updating submodule repository products"

$submoduleRootPath0 = [IO.Path]::Combine($scriptDirPath, '..', 'submodules', 'some-module')
$submoduleRootPath = $(resolve-path $submoduleRootPath0).Path

$submoduleSrcPath = [IO.Path]::Combine($submoduleRootPath, 'src')
$submoduleProductsJsonPath = [IO.Path]::Combine($submoduleRootPath, 'ver', 'products.json')
$submoduleProducts = Get-Content $submoduleProductsJsonPath | ConvertFrom-Json
UpdateProducts $submoduleSrcPath $submoduleProducts $build
#>

Write-Output "DONE"
