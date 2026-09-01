$projectId = "smart-traffic-sudan"
$apiKey = "AIzaSyB73YgI4g1DQMU_finohQUjd5q68asrDGU"

$authBody = @{ email = "admin@smarttraffic.sd"; password = "Admin@2026"; returnSecureToken = $true } | ConvertTo-Json
$auth = Invoke-RestMethod -Method POST -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey" -Body $authBody -ContentType "application/json"
$token = $auth.idToken
Write-Host "[OK] Auth success"

function Set-FsDoc($col, $docId, $fields) {
    $url = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$col/$docId"
    $body = @{ fields = $fields } | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Method PATCH -Uri $url -Headers @{ Authorization = "Bearer $token" } -Body $body -ContentType "application/json" | Out-Null
    Write-Host "  [SET] $col/$docId"
}

# vehicles
Set-FsDoc "vehicles" "VEH-SAMPLE" @{
    id = @{ stringValue = "VEH-SAMPLE" }; userId = @{ stringValue = "system" }
    make = @{ stringValue = "تويوتا" }; model = @{ stringValue = "كورولا" }
    plateNumber = @{ stringValue = "خ 5 1234" }; color = @{ stringValue = "أبيض" }
    chassisNumber = @{ stringValue = "JTDBP65E700123456" }
    certificateImageUrl = @{ stringValue = "" }
    isVerified = @{ booleanValue = $true }; isWanted = @{ booleanValue = $false }
    createdAt = @{ timestampValue = "2026-08-20T00:00:00Z" }
}

# violations
Set-FsDoc "violations" "VIO-SAMPLE" @{
    id = @{ stringValue = "VIO-SAMPLE" }; userId = @{ stringValue = "system" }
    vehicleId = @{ stringValue = "VEH-SAMPLE" }
    plateNumber = @{ stringValue = "خ 5 1234" }
    violationType = @{ stringValue = "تجاوز الإشارة الحمراء" }
    amount = @{ doubleValue = 50000 }; status = @{ stringValue = "pending" }
    locationName = @{ stringValue = "تقاطع المطار" }
    latitude = @{ doubleValue = 15.6008 }; longitude = @{ doubleValue = 32.5325 }
    officerName = @{ stringValue = "الملازم أحمد" }; officerBadge = @{ stringValue = "OFFICER-001" }
    date = @{ timestampValue = "2026-08-20T00:00:00Z" }
    createdAt = @{ timestampValue = "2026-08-20T00:00:00Z" }
}

# disputes
Set-FsDoc "disputes" "DIS-SAMPLE" @{
    id = @{ stringValue = "DIS-SAMPLE" }; violationId = @{ stringValue = "VIO-SAMPLE" }
    userId = @{ stringValue = "system" }; reason = @{ stringValue = "الإشارة لم تكن تعمل" }
    status = @{ stringValue = "pending" }; adminResponse = @{ stringValue = "" }
    createdAt = @{ timestampValue = "2026-08-20T00:00:00Z" }
}

# otp_codes
Set-FsDoc "otp_codes" "_schema_" @{
    note = @{ stringValue = "OTP verification codes - auto-deleted after use" }
    codeHash = @{ stringValue = "sha256_hash" }; attempts = @{ integerValue = "0" }
    expiry = @{ timestampValue = "2026-01-01T00:00:00Z" }
}

# notifications
Set-FsDoc "notifications" "NOTIF-SAMPLE" @{
    id = @{ stringValue = "NOTIF-SAMPLE" }; userId = @{ stringValue = "system" }
    title = @{ stringValue = "مرحباً في التطبيق" }
    body = @{ stringValue = "تم تفعيل حسابك في منظومة المرور الذكية" }
    type = @{ stringValue = "welcome" }; isRead = @{ booleanValue = $false }
    createdAt = @{ timestampValue = "2026-08-20T00:00:00Z" }
}

# announcements
Set-FsDoc "announcements" "ANN-SAMPLE" @{
    id = @{ stringValue = "ANN-SAMPLE" }
    title = @{ stringValue = "انطلاق منظومة المرور الذكية" }
    body = @{ stringValue = "يمكنك الآن تسجيل مركباتك ودفع المخالفات إلكترونياً عبر التطبيق." }
    isActive = @{ booleanValue = $true }
    createdAt = @{ timestampValue = "2026-08-20T00:00:00Z" }
}

Write-Host "`n[DONE] All 6 collections created in Firestore!"
