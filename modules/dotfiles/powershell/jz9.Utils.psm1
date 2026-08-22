function Get-StringHash {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$String,

        [Parameter()]
        [ValidateSet("SHA1", "SHA256", "SHA384", "SHA512", "MD5")]
        [string]$Algorithm = "SHA256"
    )

    process {
        foreach ($s in $String) {
            $stringAsStream = [System.IO.MemoryStream]::new()
            $writer = [System.IO.StreamWriter]::new($stringAsStream)
            $writer.Write($s)
            $writer.Flush()
            $stringAsStream.Position = 0
            Get-FileHash -InputStream $stringAsStream -Algorithm $Algorithm | Select-Object Algorithm, Hash
        }
    }
}

Export-ModuleMember -Function Get-StringHash

function Get-MerkleTree {
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter()]
        [string]$RelativeBasePath
    )

    process {
        foreach ($p in $Path) {
            $item = Get-Item $p
            $base = if ([string]::IsNullOrEmpty($RelativeBasePath)) { Split-Path -Parent $item.FullName } else { $RelativeBasePath }
            if ($item.PSIsContainer) {
                $children = @(Get-ChildItem $item | Sort-Object -Property Name | Get-MerkleTree -RelativeBasePath $base)
                $childHash = ($children | ForEach-Object {$_["hash"]}) -join ""
                $hash = Get-StringHash $childHash | Select-Object -ExpandProperty Hash
                [ordered]@{
                    path = Resolve-Path $p -RelativeBasePath $base -Relative
                    hash = $hash
                    children = $children
                }
            } else {
                $hash = Get-FileHash $p | Select-Object -ExpandProperty Hash
                [ordered]@{
                    path = Resolve-Path $p -RelativeBasePath $base -Relative
                    hash = $hash
                    children = @()
                }
            }
        }
    }
}

Export-ModuleMember -Function Get-MerkleTree
