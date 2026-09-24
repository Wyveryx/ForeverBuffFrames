local _, FBF = ...

local Locale = {}
FBF.Locale = Locale

Locale.supported = {
    { "auto", "Automatic" },
    { "enUS", "English" },
    { "enGB", "English (United Kingdom)" },
    { "deDE", "Deutsch" },
    { "esES", "Español (España)" },
    { "esMX", "Español (Latinoamérica)" },
    { "frFR", "Français" },
    { "itIT", "Italiano" },
    { "koKR", "한국어" },
    { "ptBR", "Português (Brasil)" },
    { "ruRU", "Русский" },
    { "zhCN", "简体中文" },
    { "zhTW", "繁體中文" },
}

local supported = {}
for _, entry in ipairs(Locale.supported) do supported[entry[1]] = true end

local translations = {
    deDE = {
        ["Language"] = "Sprache", ["Language settings"] = "Spracheinstellungen",
        ["General"] = "Allgemein", ["Buffs"] = "Stärkungszauber", ["Debuffs"] = "Schwächungszauber",
        ["Alerts"] = "Warnungen", ["Profiles"] = "Profile", ["Backup / Recovery"] = "Sicherung / Wiederherstellung",
        ["Automatic"] = "Automatisch", ["Interface language"] = "Oberflächensprache",
        ["Client language"] = "Clientsprache", ["Displayed language"] = "Angezeigte Sprache",
        ["Apply and reload"] = "Anwenden und neu laden", ["Close"] = "Schließen",
    },
    esES = {
        ["Language"] = "Idioma", ["Language settings"] = "Opciones de idioma",
        ["General"] = "General", ["Buffs"] = "Beneficios", ["Debuffs"] = "Perjuicios",
        ["Alerts"] = "Alertas", ["Profiles"] = "Perfiles", ["Backup / Recovery"] = "Copia / Recuperación",
        ["Automatic"] = "Automático", ["Interface language"] = "Idioma de la interfaz",
        ["Client language"] = "Idioma del cliente", ["Displayed language"] = "Idioma mostrado",
        ["Apply and reload"] = "Aplicar y recargar", ["Close"] = "Cerrar",
    },
    esMX = {
        ["Language"] = "Idioma", ["Language settings"] = "Opciones de idioma",
        ["General"] = "General", ["Buffs"] = "Beneficios", ["Debuffs"] = "Perjuicios",
        ["Alerts"] = "Alertas", ["Profiles"] = "Perfiles", ["Backup / Recovery"] = "Respaldo / Recuperación",
        ["Automatic"] = "Automático", ["Interface language"] = "Idioma de la interfaz",
        ["Client language"] = "Idioma del cliente", ["Displayed language"] = "Idioma mostrado",
        ["Apply and reload"] = "Aplicar y recargar", ["Close"] = "Cerrar",
    },
    frFR = {
        ["Language"] = "Langue", ["Language settings"] = "Paramètres de langue",
        ["General"] = "Général", ["Buffs"] = "Améliorations", ["Debuffs"] = "Affaiblissements",
        ["Alerts"] = "Alertes", ["Profiles"] = "Profils", ["Backup / Recovery"] = "Sauvegarde / Récupération",
        ["Automatic"] = "Automatique", ["Interface language"] = "Langue de l’interface",
        ["Client language"] = "Langue du client", ["Displayed language"] = "Langue affichée",
        ["Apply and reload"] = "Appliquer et recharger", ["Close"] = "Fermer",
    },
    itIT = {
        ["Language"] = "Lingua", ["Language settings"] = "Impostazioni lingua",
        ["General"] = "Generale", ["Buffs"] = "Benefici", ["Debuffs"] = "Penalità",
        ["Alerts"] = "Avvisi", ["Profiles"] = "Profili", ["Backup / Recovery"] = "Backup / Ripristino",
        ["Automatic"] = "Automatico", ["Interface language"] = "Lingua dell’interfaccia",
        ["Client language"] = "Lingua del client", ["Displayed language"] = "Lingua visualizzata",
        ["Apply and reload"] = "Applica e ricarica", ["Close"] = "Chiudi",
    },
    koKR = {
        ["Language"] = "언어", ["Language settings"] = "언어 설정",
        ["General"] = "일반", ["Buffs"] = "강화 효과", ["Debuffs"] = "약화 효과",
        ["Alerts"] = "알림", ["Profiles"] = "프로필", ["Backup / Recovery"] = "백업 / 복구",
        ["Automatic"] = "자동", ["Interface language"] = "인터페이스 언어",
        ["Client language"] = "클라이언트 언어", ["Displayed language"] = "표시 언어",
        ["Apply and reload"] = "적용 후 다시 불러오기", ["Close"] = "닫기",
    },
    ptBR = {
        ["Language"] = "Idioma", ["Language settings"] = "Configurações de idioma",
        ["General"] = "Geral", ["Buffs"] = "Bônus", ["Debuffs"] = "Penalidades",
        ["Alerts"] = "Alertas", ["Profiles"] = "Perfis", ["Backup / Recovery"] = "Backup / Recuperação",
        ["Automatic"] = "Automático", ["Interface language"] = "Idioma da interface",
        ["Client language"] = "Idioma do cliente", ["Displayed language"] = "Idioma exibido",
        ["Apply and reload"] = "Aplicar e recarregar", ["Close"] = "Fechar",
    },
    ruRU = {
        ["Language"] = "Язык", ["Language settings"] = "Настройки языка",
        ["General"] = "Общие", ["Buffs"] = "Положительные эффекты", ["Debuffs"] = "Отрицательные эффекты",
        ["Alerts"] = "Оповещения", ["Profiles"] = "Профили", ["Backup / Recovery"] = "Резервная копия / Восстановление",
        ["Automatic"] = "Автоматически", ["Interface language"] = "Язык интерфейса",
        ["Client language"] = "Язык клиента", ["Displayed language"] = "Отображаемый язык",
        ["Apply and reload"] = "Применить и перезагрузить", ["Close"] = "Закрыть",
    },
    zhCN = {
        ["Language"] = "语言", ["Language settings"] = "语言设置",
        ["General"] = "常规", ["Buffs"] = "增益", ["Debuffs"] = "减益",
        ["Alerts"] = "提醒", ["Profiles"] = "配置方案", ["Backup / Recovery"] = "备份 / 恢复",
        ["Automatic"] = "自动", ["Interface language"] = "界面语言",
        ["Client language"] = "客户端语言", ["Displayed language"] = "显示语言",
        ["Apply and reload"] = "应用并重载", ["Close"] = "关闭",
    },
    zhTW = {
        ["Language"] = "語言", ["Language settings"] = "語言設定",
        ["General"] = "一般", ["Buffs"] = "增益效果", ["Debuffs"] = "減益效果",
        ["Alerts"] = "提醒", ["Profiles"] = "設定檔", ["Backup / Recovery"] = "備份 / 還原",
        ["Automatic"] = "自動", ["Interface language"] = "介面語言",
        ["Client language"] = "用戶端語言", ["Displayed language"] = "顯示語言",
        ["Apply and reload"] = "套用並重新載入", ["Close"] = "關閉",
    },
}

-- Compact parallel lists keep the full set of control labels reviewable across
-- every locale. English keys are the fallback for untranslated explanatory text.
local controlKeys = {
    "Icon size", "Horizontal spacing", "Vertical spacing", "Icons per row", "Rows",
    "Timer text size", "Stack text size", "Growth", "Aura order", "Unlimited auras",
    "Timer position", "Stack position", "Outline", "Grow right", "Grow left",
    "Default order", "Shortest remaining first", "Longest remaining first", "Default placement",
    "Place on left", "Place on right", "Below", "Above", "Centered", "Bottom right",
    "Bottom left", "Top right", "Top left", "None", "Thick outline",
}
local controlValues = {
    deDE = { "Symbolgröße", "Horizontaler Abstand", "Vertikaler Abstand", "Symbole pro Reihe", "Reihen", "Timertextgröße", "Stapeltextgröße", "Wachstum", "Aurareihenfolge", "Unbegrenzte Auren", "Timerposition", "Stapelposition", "Kontur", "Nach rechts", "Nach links", "Standardreihenfolge", "Kürzeste zuerst", "Längste zuerst", "Standardplatzierung", "Links platzieren", "Rechts platzieren", "Unten", "Oben", "Zentriert", "Unten rechts", "Unten links", "Oben rechts", "Oben links", "Keine", "Dicke Kontur" },
    esES = { "Tamaño de icono", "Espaciado horizontal", "Espaciado vertical", "Iconos por fila", "Filas", "Tamaño del texto del tiempo", "Tamaño del texto de acumulación", "Dirección", "Orden de auras", "Auras ilimitadas", "Posición del tiempo", "Posición de acumulaciones", "Contorno", "Crecer a la derecha", "Crecer a la izquierda", "Orden predeterminado", "Menor duración primero", "Mayor duración primero", "Posición predeterminada", "Colocar a la izquierda", "Colocar a la derecha", "Debajo", "Encima", "Centrado", "Abajo a la derecha", "Abajo a la izquierda", "Arriba a la derecha", "Arriba a la izquierda", "Ninguno", "Contorno grueso" },
    esMX = { "Tamaño de icono", "Espaciado horizontal", "Espaciado vertical", "Iconos por fila", "Filas", "Tamaño del texto del tiempo", "Tamaño del texto de acumulación", "Dirección", "Orden de auras", "Auras ilimitadas", "Posición del tiempo", "Posición de acumulaciones", "Contorno", "Crecer a la derecha", "Crecer a la izquierda", "Orden predeterminado", "Menor duración primero", "Mayor duración primero", "Posición predeterminada", "Colocar a la izquierda", "Colocar a la derecha", "Abajo", "Arriba", "Centrado", "Abajo a la derecha", "Abajo a la izquierda", "Arriba a la derecha", "Arriba a la izquierda", "Ninguno", "Contorno grueso" },
    frFR = { "Taille des icônes", "Espacement horizontal", "Espacement vertical", "Icônes par ligne", "Lignes", "Taille du texte du minuteur", "Taille du texte des charges", "Déploiement", "Ordre des auras", "Auras illimitées", "Position du minuteur", "Position des charges", "Contour", "Vers la droite", "Vers la gauche", "Ordre par défaut", "Durée la plus courte", "Durée la plus longue", "Placement par défaut", "Placer à gauche", "Placer à droite", "En dessous", "Au-dessus", "Centré", "En bas à droite", "En bas à gauche", "En haut à droite", "En haut à gauche", "Aucun", "Contour épais" },
    itIT = { "Dimensione icona", "Spaziatura orizzontale", "Spaziatura verticale", "Icone per riga", "Righe", "Dimensione testo durata", "Dimensione testo accumuli", "Direzione", "Ordine aure", "Aure illimitate", "Posizione durata", "Posizione accumuli", "Contorno", "Cresci a destra", "Cresci a sinistra", "Ordine predefinito", "Durata minore prima", "Durata maggiore prima", "Posizione predefinita", "Posiziona a sinistra", "Posiziona a destra", "Sotto", "Sopra", "Centrato", "In basso a destra", "In basso a sinistra", "In alto a destra", "In alto a sinistra", "Nessuno", "Contorno spesso" },
    koKR = { "아이콘 크기", "가로 간격", "세로 간격", "한 줄 아이콘 수", "줄 수", "시간 글자 크기", "중첩 글자 크기", "확장 방향", "효과 정렬", "무제한 효과", "시간 위치", "중첩 위치", "외곽선", "오른쪽으로", "왼쪽으로", "기본 정렬", "짧은 시간 우선", "긴 시간 우선", "기본 배치", "왼쪽에 배치", "오른쪽에 배치", "아래", "위", "가운데", "오른쪽 아래", "왼쪽 아래", "오른쪽 위", "왼쪽 위", "없음", "굵은 외곽선" },
    ptBR = { "Tamanho do ícone", "Espaçamento horizontal", "Espaçamento vertical", "Ícones por linha", "Linhas", "Tamanho do texto do tempo", "Tamanho do texto das aplicações", "Crescimento", "Ordem das auras", "Auras ilimitadas", "Posição do tempo", "Posição das aplicações", "Contorno", "Crescer à direita", "Crescer à esquerda", "Ordem padrão", "Menor duração primeiro", "Maior duração primeiro", "Posição padrão", "Colocar à esquerda", "Colocar à direita", "Abaixo", "Acima", "Centralizado", "Inferior direito", "Inferior esquerdo", "Superior direito", "Superior esquerdo", "Nenhum", "Contorno grosso" },
    ruRU = { "Размер значка", "Горизонтальный интервал", "Вертикальный интервал", "Значков в ряду", "Ряды", "Размер текста таймера", "Размер текста зарядов", "Направление роста", "Порядок эффектов", "Бессрочные эффекты", "Положение таймера", "Положение зарядов", "Контур", "Рост вправо", "Рост влево", "Обычный порядок", "Сначала короткие", "Сначала длинные", "Обычное размещение", "Размещать слева", "Размещать справа", "Снизу", "Сверху", "По центру", "Справа внизу", "Слева внизу", "Справа вверху", "Слева вверху", "Нет", "Толстый контур" },
    zhCN = { "图标大小", "水平间距", "垂直间距", "每行图标数", "行数", "计时文字大小", "层数文字大小", "增长方向", "光环排序", "永久光环", "计时位置", "层数位置", "轮廓", "向右增长", "向左增长", "默认排序", "剩余时间短的优先", "剩余时间长的优先", "默认位置", "置于左侧", "置于右侧", "下方", "上方", "居中", "右下", "左下", "右上", "左上", "无", "粗轮廓" },
    zhTW = { "圖示大小", "水平間距", "垂直間距", "每列圖示數", "列數", "計時文字大小", "層數文字大小", "延伸方向", "效果排序", "永久效果", "計時位置", "層數位置", "外框", "向右延伸", "向左延伸", "預設排序", "剩餘時間短的優先", "剩餘時間長的優先", "預設位置", "放置於左側", "放置於右側", "下方", "上方", "置中", "右下", "左下", "右上", "左上", "無", "粗外框" },
}
for locale, values in pairs(controlValues) do
    for index, key in ipairs(controlKeys) do translations[locale][key] = values[index] end
end

local actionKeys = {
    "Layout", "Text", "Font", "Toggle test icons", "Reset this bar", "Named profiles",
    "Profile name", "Create new", "Copy active", "Rename", "Delete active", "Copy backup code",
    "Restore pasted code", "Play test sound", "Alert blacklist", "Block ID", "Unblock ID",
    "General options", "Configuration text size", "Minimum duration (sec)", "Alert sound",
    "Lock bars", "Unlock bars", "Active profile",
}
local actionValues = {
    deDE = { "Anordnung", "Textanzeige", "Schriftart", "Testsymbole umschalten", "Diese Leiste zurücksetzen", "Benannte Profile", "Profilname", "Neu erstellen", "Aktives kopieren", "Umbenennen", "Aktives löschen", "Sicherungscode kopieren", "Eingefügten Code wiederherstellen", "Testton abspielen", "Warnungs-Blacklist", "ID sperren", "ID entsperren", "Allgemeine Optionen", "Textgröße der Konfiguration", "Mindestdauer (Sek.)", "Warnton", "Leisten sperren", "Leisten entsperren", "Aktives Profil" },
    esES = { "Diseño", "Texto", "Fuente", "Alternar iconos de prueba", "Restablecer esta barra", "Perfiles guardados", "Nombre del perfil", "Crear nuevo", "Copiar activo", "Renombrar", "Eliminar activo", "Copiar código de respaldo", "Restaurar código pegado", "Reproducir sonido de prueba", "Lista negra de alertas", "Bloquear ID", "Desbloquear ID", "Opciones generales", "Tamaño del texto de configuración", "Duración mínima (s)", "Sonido de alerta", "Bloquear barras", "Desbloquear barras", "Perfil activo" },
    esMX = { "Diseño", "Texto", "Fuente", "Alternar iconos de prueba", "Restablecer esta barra", "Perfiles guardados", "Nombre del perfil", "Crear nuevo", "Copiar activo", "Renombrar", "Eliminar activo", "Copiar código de respaldo", "Restaurar código pegado", "Reproducir sonido de prueba", "Lista negra de alertas", "Bloquear ID", "Desbloquear ID", "Opciones generales", "Tamaño del texto de configuración", "Duración mínima (s)", "Sonido de alerta", "Bloquear barras", "Desbloquear barras", "Perfil activo" },
    frFR = { "Disposition", "Texte", "Police", "Afficher les icônes de test", "Réinitialiser cette barre", "Profils nommés", "Nom du profil", "Créer", "Copier l’actif", "Renommer", "Supprimer l’actif", "Copier le code de sauvegarde", "Restaurer le code collé", "Tester le son", "Liste noire des alertes", "Bloquer l’ID", "Débloquer l’ID", "Options générales", "Taille du texte de configuration", "Durée minimale (s)", "Son d’alerte", "Verrouiller les barres", "Déverrouiller les barres", "Profil actif" },
    itIT = { "Disposizione", "Testo", "Carattere", "Mostra icone di prova", "Reimposta questa barra", "Profili nominati", "Nome profilo", "Crea nuovo", "Copia attivo", "Rinomina", "Elimina attivo", "Copia codice backup", "Ripristina codice incollato", "Riproduci suono di prova", "Lista nera avvisi", "Blocca ID", "Sblocca ID", "Opzioni generali", "Dimensione testo configurazione", "Durata minima (sec)", "Suono di avviso", "Blocca barre", "Sblocca barre", "Profilo attivo" },
    koKR = { "배치", "텍스트 표시", "글꼴", "테스트 아이콘 전환", "이 바 초기화", "프로필", "프로필 이름", "새로 만들기", "활성 프로필 복사", "이름 변경", "활성 프로필 삭제", "백업 코드 복사", "붙여넣은 코드 복원", "테스트 소리 재생", "알림 차단 목록", "ID 차단", "ID 차단 해제", "일반 옵션", "설정 글자 크기", "최소 지속시간(초)", "알림 소리", "바 잠금", "바 잠금 해제", "활성 프로필" },
    ptBR = { "Disposição", "Texto", "Fonte", "Alternar ícones de teste", "Redefinir esta barra", "Perfis nomeados", "Nome do perfil", "Criar novo", "Copiar ativo", "Renomear", "Excluir ativo", "Copiar código de backup", "Restaurar código colado", "Tocar som de teste", "Lista de bloqueio de alertas", "Bloquear ID", "Desbloquear ID", "Opções gerais", "Tamanho do texto da configuração", "Duração mínima (s)", "Som de alerta", "Bloquear barras", "Desbloquear barras", "Perfil ativo" },
    ruRU = { "Расположение", "Текст", "Шрифт", "Тестовые значки", "Сбросить эту панель", "Именованные профили", "Имя профиля", "Создать", "Копировать активный", "Переименовать", "Удалить активный", "Копировать код", "Восстановить код", "Проверить звук", "Чёрный список оповещений", "Заблокировать ID", "Разблокировать ID", "Общие настройки", "Размер текста настроек", "Мин. длительность (сек.)", "Звук оповещения", "Заблокировать панели", "Разблокировать панели", "Активный профиль" },
    zhCN = { "布局", "文字", "字体", "切换测试图标", "重置此栏", "命名配置方案", "配置方案名称", "新建", "复制当前", "重命名", "删除当前", "复制备份代码", "恢复粘贴的代码", "播放测试音效", "提醒黑名单", "屏蔽 ID", "取消屏蔽 ID", "常规选项", "设置界面文字大小", "最短持续时间（秒）", "提醒音效", "锁定栏", "解锁栏", "当前配置方案" },
    zhTW = { "版面", "文字", "字型", "切換測試圖示", "重設此列", "命名設定檔", "設定檔名稱", "新增", "複製目前設定", "重新命名", "刪除目前設定", "複製備份代碼", "還原貼上的代碼", "播放測試音效", "提醒黑名單", "封鎖 ID", "解除封鎖 ID", "一般選項", "設定介面文字大小", "最短持續時間（秒）", "提醒音效", "鎖定列", "解鎖列", "目前設定檔" },
}
for locale, values in pairs(actionValues) do
    for index, key in ipairs(actionKeys) do translations[locale][key] = values[index] end
end

local toggleKeys = { "Show minimap button", "Hide Blizzard buffs", "Hide Blizzard debuffs", "10-second expiry alert", "Only buffs I cast", "Debug expiry alerts" }
local toggleValues = {
    deDE = { "Minikartenknopf anzeigen", "Blizzard-Stärkungszauber ausblenden", "Blizzard-Schwächungszauber ausblenden", "Ablaufwarnung bei 10 Sekunden", "Nur von mir gewirkte Stärkungszauber", "Ablaufwarnungen debuggen" },
    esES = { "Mostrar botón del minimapa", "Ocultar beneficios de Blizzard", "Ocultar perjuicios de Blizzard", "Alerta a 10 segundos", "Solo beneficios lanzados por mí", "Depurar alertas" },
    esMX = { "Mostrar botón del minimapa", "Ocultar beneficios de Blizzard", "Ocultar perjuicios de Blizzard", "Alerta a 10 segundos", "Solo beneficios lanzados por mí", "Depurar alertas" },
    frFR = { "Afficher le bouton de minicarte", "Masquer les améliorations Blizzard", "Masquer les affaiblissements Blizzard", "Alerte à 10 secondes", "Uniquement mes améliorations", "Déboguer les alertes" },
    itIT = { "Mostra pulsante minimappa", "Nascondi benefici Blizzard", "Nascondi penalità Blizzard", "Avviso a 10 secondi", "Solo benefici lanciati da me", "Debug avvisi" },
    koKR = { "미니맵 버튼 표시", "블리자드 강화 효과 숨기기", "블리자드 약화 효과 숨기기", "10초 만료 알림", "내가 시전한 강화 효과만", "만료 알림 디버그" },
    ptBR = { "Mostrar botão do minimapa", "Ocultar bônus da Blizzard", "Ocultar penalidades da Blizzard", "Alerta de expiração em 10 segundos", "Somente bônus lançados por mim", "Depurar alertas" },
    ruRU = { "Показывать кнопку у миникарты", "Скрыть эффекты Blizzard", "Скрыть отрицательные эффекты Blizzard", "Оповещение за 10 секунд", "Только мои эффекты", "Отладка оповещений" },
    zhCN = { "显示小地图按钮", "隐藏暴雪增益", "隐藏暴雪减益", "提前 10 秒提醒", "仅限我施放的增益", "调试到期提醒" },
    zhTW = { "顯示小地圖按鈕", "隱藏暴雪增益效果", "隱藏暴雪減益效果", "提前 10 秒提醒", "僅限我施放的增益效果", "偵錯到期提醒" },
}
for locale, values in pairs(toggleValues) do
    for index, key in ipairs(toggleKeys) do translations[locale][key] = values[index] end
end

local de = translations.deDE
de["Close the configuration window. Settings are saved automatically."] = "Schließt das Konfigurationsfenster. Einstellungen werden automatisch gespeichert."
de["Width and height of each aura icon, in pixels."] = "Breite und Höhe jedes Aurasymbols in Pixeln."
de["Space between icons in the same row, in pixels."] = "Abstand zwischen Symbolen derselben Reihe in Pixeln."
de["Space between rows, in pixels."] = "Abstand zwischen den Reihen in Pixeln."
de["Maximum number of icons before the next row begins."] = "Maximale Anzahl von Symbolen, bevor eine neue Reihe beginnt."
de["Maximum number of rows shown in this bar."] = "Maximale Anzahl der in dieser Leiste angezeigten Reihen."
de["Font size of the remaining-duration text."] = "Schriftgröße der verbleibenden Dauer."
de["Font size of the stack-count number."] = "Schriftgröße der Stapelanzahl."
de["Direction icons fill each row."] = "Richtung, in der die Symbole jede Reihe füllen."
de["Order auras using Blizzard's protected container sorter. Permanent-aura placement will be verified in game."] = "Sortiert Auren mit Blizzards geschützter Containersortierung. Die Platzierung permanenter Auren wird im Spiel geprüft."
de["Keep Blizzard's default placement, or group known unlimited auras on a physical side. New classifications may update after combat."] = "Behält Blizzards Standardplatzierung bei oder gruppiert bekannte unbegrenzte Auren auf einer Seite. Neue Zuordnungen können nach dem Kampf aktualisiert werden."
de["Where duration text appears relative to each icon."] = "Position des Dauertexts relativ zum Symbol."
de["Corner used for the stack-count number."] = "Ecke für die Anzeige der Stapelanzahl."
de["Border weight around timer and stack text."] = "Stärke der Kontur um Timer- und Stapeltext."
de[" Drag the slider or use the mouse wheel for one-point steps."] = " Ziehe den Regler oder benutze das Mausrad für Einzelschritte."
de[" exact value"] = " – genauer Wert"
de[" Type a whole number from %d to %d, then press Enter."] = " Gib eine ganze Zahl von %d bis %d ein und drücke die Eingabetaste."
de[" Click to choose an option."] = " Klicke, um eine Option auszuwählen."
de["Automatic follows the WoW client language. Select another language to review its translation, then reload the interface."] = "Automatisch verwendet die Sprache des WoW-Clients. Wähle zum Prüfen einer Übersetzung eine andere Sprache und lade anschließend die Benutzeroberfläche neu."
de["Each profile stores the complete ForeverBuffFrames setup. The active profile is saved automatically. Backup codes continue to protect all profiles from the current beta settings bug."] = "Jedes Profil speichert die vollständige ForeverBuffFrames-Konfiguration. Das aktive Profil wird automatisch gespeichert. Sicherungscodes schützen weiterhin alle Profile vor dem aktuellen Fehler der Beta."
de["Why is this here?"] = "Warum gibt es diese Funktion?"
de["The current WoW beta sometimes forgets addon settings after a reload or restart. Save a backup code outside the game now; paste it back here if your setup disappears. The addon cannot save a separate recovery file itself."] = "Die aktuelle WoW-Beta vergisst nach einem Neuladen oder Neustart manchmal Addon-Einstellungen. Speichere einen Sicherungscode außerhalb des Spiels und füge ihn hier ein, falls deine Konfiguration verschwindet. Das Addon kann selbst keine separate Wiederherstellungsdatei speichern."
de["1. Save your profiles"] = "1. Profile sichern"
de["Click Copy backup code below, press Ctrl+C, then paste it into Notepad and save the file. The code contains every named profile and the active-profile selection."] = "Klicke unten auf Sicherungscode kopieren, drücke Strg+C und füge den Code in den Editor ein. Speichere anschließend die Datei. Der Code enthält alle benannten Profile und die Auswahl des aktiven Profils."
de["2. Restore your profiles"] = "2. Profile wiederherstellen"
de["Paste the code from your saved file into the box below and click Restore pasted code. New backup codes replace all profiles; older backup codes restore into the active profile."] = "Füge den Code aus deiner gespeicherten Datei unten ein und klicke auf Eingefügten Code wiederherstellen. Neue Sicherungscodes ersetzen alle Profile; ältere Codes werden im aktiven Profil wiederhergestellt."
de["Sound and raid warning play together at 10 seconds remaining. Live alerts require an out-of-combat aura check; they are skipped during combat."] = "Bei 10 Sekunden Restzeit werden Ton und Schlachtzugwarnung gemeinsam ausgelöst. Livewarnungen benötigen eine Auraprüfung außerhalb des Kampfes und werden im Kampf übersprungen."
de["Block specific buff spell IDs from triggering expiry alerts."] = "Verhindert Ablaufwarnungen für bestimmte Zauber-IDs von Stärkungszaubern."
de["These controls affect the settings window or shared game displays. Bar layout and aura ordering remain in the Buffs and Debuffs pages."] = "Diese Optionen betreffen das Einstellungsfenster oder gemeinsam genutzte Spielanzeigen. Leistenlayout und Aurareihenfolge bleiben auf den Seiten für Stärkungs- und Schwächungszauber."
de["General settings"] = "Allgemeine Einstellungen"
de["Alert settings"] = "Warnungseinstellungen"
de["Buff settings"] = "Einstellungen für Stärkungszauber"
de["Debuff settings"] = "Einstellungen für Schwächungszauber"
de["Save all profiles or restore them if the beta forgets them."] = "Sichert alle Profile oder stellt sie wieder her, falls die Beta sie vergisst."
de["Create, copy, rename, delete, and select named settings profiles."] = "Erstellt, kopiert, benennt um, löscht und wählt benannte Einstellungsprofile."
de["Configure the settings window and shared display choices."] = "Konfiguriert das Einstellungsfenster und gemeinsam genutzte Anzeigeoptionen."
de["Choose the automatic client language or override it to test a translation."] = "Verwendet automatisch die Clientsprache oder überschreibt sie zum Prüfen einer Übersetzung."
de["Configure ten-second warnings and their blacklist."] = "Konfiguriert Zehn-Sekunden-Warnungen und deren Blacklist."
de["Configure this bar independently from the other bar."] = "Konfiguriert diese Leiste unabhängig von der anderen Leiste."
de["Test icons"] = "Testsymbole"
de["Move bars"] = "Leisten verschieben"
de["Create new profile"] = "Neues Profil erstellen"
de["Copy active profile"] = "Aktives Profil kopieren"
de["Rename active profile"] = "Aktives Profil umbenennen"
de["Delete active profile"] = "Aktives Profil löschen"
de["Spell ID"] = "Zauber-ID"
de["Minimum buff duration"] = "Mindestdauer des Stärkungszaubers"
de["Open configuration"] = "Konfiguration öffnen"
de["Choose a font with a live typeface preview. Installed media packs appear here too."] = "Wählt eine Schriftart mit Livevorschau. Installierte Medienpakete werden ebenfalls angezeigt."
de["Show sample icons in place of live auras. Click the first sample icon for a 15-second alert preview. Click again to restore live auras."] = "Zeigt Testsymbole anstelle aktiver Auren. Klicke auf das erste Symbol für eine 15-sekündige Warnungsvorschau. Klicke erneut, um die aktiven Auren wiederherzustellen."
de["Unlock to drag a bar itself or its label. Lock again when finished; positions save automatically."] = "Entsperre die Leisten, um eine Leiste selbst oder ihre Beschriftung zu ziehen. Sperre sie anschließend wieder; Positionen werden automatisch gespeichert."
de["Restore this bar's default layout, text settings, and position."] = "Stellt Standardlayout, Texteinstellungen und Position dieser Leiste wieder her."
de["Click to select another saved profile."] = "Klicke, um ein anderes gespeichertes Profil auszuwählen."
de["Enter a name for Create, Copy, or Rename."] = "Gib einen Namen zum Erstellen, Kopieren oder Umbenennen ein."
de["Create and select a profile using default settings."] = "Erstellt und wählt ein Profil mit Standardeinstellungen."
de["Make and select a copy of the current profile."] = "Erstellt und wählt eine Kopie des aktuellen Profils."
de["Rename the current profile without changing its settings."] = "Benennt das aktuelle Profil um, ohne seine Einstellungen zu ändern."
de["Permanently delete the current profile and select another one. At least one profile must remain."] = "Löscht das aktuelle Profil dauerhaft und wählt ein anderes aus. Mindestens ein Profil muss erhalten bleiben."
de["Play the sound used for the ten-second expiration warning."] = "Spielt den Ton der Ablaufwarnung bei zehn Sekunden ab."
de["Search sounds. Play previews a sound; click its name to select it. None keeps the raid warning silent."] = "Durchsucht Töne. Abspielen gibt eine Vorschau wieder; klicke zum Auswählen auf den Namen. Keine lässt die Schlachtzugwarnung stumm."
de["Enter the numeric ID of a buff to exclude or restore."] = "Gib die numerische ID eines auszuschließenden oder wieder zu aktivierenden Stärkungszaubers ein."
de["Increase text throughout the ForeverBuffFrames settings window without changing the aura text on your bars."] = "Vergrößert den Text im ForeverBuffFrames-Einstellungsfenster, ohne den Auratext auf den Leisten zu ändern."
de["Only watch buffs lasting at least this many seconds. Enter a whole number from 0 to 3600; 0 includes all durations."] = "Überwacht nur Stärkungszauber, die mindestens so lange dauern. Gib eine ganze Zahl von 0 bis 3600 ein; 0 berücksichtigt alle Dauern."
de["Open the full ForeverBuffFrames settings window."] = "Öffnet das vollständige ForeverBuffFrames-Einstellungsfenster."
de["Keep a button on the minimap that opens this window. /fbf config always works."] = "Zeigt einen Minikartenknopf zum Öffnen dieses Fensters. /fbf config funktioniert immer."
de["Hide the game's original player buff display. Turn this off to restore it."] = "Blendet die ursprüngliche Blizzard-Anzeige für Stärkungszauber aus. Deaktiviere diese Option, um sie wieder anzuzeigen."
de["Hide the game's original player debuff display. Turn this off to restore it."] = "Blendet die ursprüngliche Blizzard-Anzeige für Schwächungszauber aus. Deaktiviere diese Option, um sie wieder anzuzeigen."
de["Play a sound and show a raid warning when a watched buff has 10 seconds left. Requires an out-of-combat aura check; alerts are skipped during combat."] = "Spielt einen Ton ab und zeigt eine Schlachtzugwarnung, wenn ein überwachter Stärkungszauber noch 10 Sekunden hält. Benötigt eine Auraprüfung außerhalb des Kampfes; Warnungen werden im Kampf übersprungen."
de["Watch buffs cast by your character. Turn this off to include buffs cast by others."] = "Überwacht von deinem Charakter gewirkte Stärkungszauber. Deaktiviere dies, um auch Zauber anderer Spieler einzubeziehen."
de["Print scheduled, skipped, and fired alerts outside combat. Aura details are unavailable to the addon during combat."] = "Gibt geplante, übersprungene und ausgelöste Warnungen außerhalb des Kampfes aus. Im Kampf sind Auradetails für das Addon nicht verfügbar."
de["Default"] = "Standard"
de["Unit name"] = "Einheitenname"
de["Damage"] = "Schaden"
de["Original warning"] = "Originalwarnung"
de["Raid warning"] = "Schlachtzugwarnung"
de["Ready check"] = "Bereitschaftscheck"
de["Level up"] = "Stufenaufstieg"
de["Quest complete"] = "Quest abgeschlossen"
de["Whisper"] = "Flüstern"
de["Play"] = "Abspielen"
de["Choose font"] = "Schriftart auswählen"
de["Choose alert sound"] = "Warnton auswählen"
de["Search fonts; names preview their typeface"] = "Schriftarten durchsuchen; Namen zeigen eine Vorschau"
de["Search sounds; Play previews without selecting"] = "Töne durchsuchen; Abspielen gibt eine Vorschau ohne Auswahl wieder"
de["Unknown spell"] = "Unbekannter Zauber"
de["No spells blacklisted."] = "Keine Zauber auf der Blacklist."
de["Standard"] = "Standard"

local detailKeys = {
    "Width and height of each aura icon, in pixels.", "Space between icons in the same row, in pixels.",
    "Space between rows, in pixels.", "Maximum number of icons before the next row begins.",
    "Maximum number of rows shown in this bar.", "Font size of the remaining-duration text.",
    "Font size of the stack-count number.", "Direction icons fill each row.",
    "Order auras using Blizzard's protected container sorter. Permanent-aura placement will be verified in game.",
    "Keep Blizzard's default placement, or group known unlimited auras on a physical side. New classifications may update after combat.",
    "Where duration text appears relative to each icon.", "Corner used for the stack-count number.",
    "Border weight around timer and stack text.", " Drag the slider or use the mouse wheel for one-point steps.",
    " exact value", " Type a whole number from %d to %d, then press Enter.", " Click to choose an option.",
    "Automatic follows the WoW client language. Select another language to review its translation, then reload the interface.",
    "Each profile stores the complete ForeverBuffFrames setup. The active profile is saved automatically. Backup codes continue to protect all profiles from the current beta settings bug.",
    "Why is this here?", "1. Save your profiles", "2. Restore your profiles",
    "Sound and raid warning play together at 10 seconds remaining. Live alerts require an out-of-combat aura check; they are skipped during combat.",
    "Block specific buff spell IDs from triggering expiry alerts.",
    "These controls affect the settings window or shared game displays. Bar layout and aura ordering remain in the Buffs and Debuffs pages.",
}
local detailValues = {
    frFR = {
        "Largeur et hauteur de chaque icône d’aura, en pixels.", "Espace entre les icônes d’une même ligne, en pixels.",
        "Espace entre les lignes, en pixels.", "Nombre maximal d’icônes avant de commencer une nouvelle ligne.",
        "Nombre maximal de lignes affichées dans cette barre.", "Taille du texte de durée restante.",
        "Taille du nombre de charges.", "Direction dans laquelle les icônes remplissent chaque ligne.",
        "Trie les auras avec le conteneur protégé de Blizzard. Le placement des auras permanentes doit être vérifié en jeu.",
        "Conserve le placement par défaut de Blizzard ou regroupe les auras permanentes connues sur un côté. Les nouvelles classifications peuvent être actualisées après le combat.",
        "Position du texte de durée par rapport à chaque icône.", "Coin utilisé pour afficher le nombre de charges.",
        "Épaisseur du contour du minuteur et du nombre de charges.", " Faites glisser le curseur ou utilisez la molette pour avancer point par point.",
        " – valeur exacte", " Saisissez un nombre entier compris entre %d et %d, puis appuyez sur Entrée.", " Cliquez pour choisir une option.",
        "Automatique suit la langue du client WoW. Sélectionnez une autre langue pour vérifier sa traduction, puis rechargez l’interface.",
        "Chaque profil conserve toute la configuration de ForeverBuffFrames. Le profil actif est enregistré automatiquement. Les codes de sauvegarde protègent tous les profils contre le problème actuel de la bêta.",
        "Pourquoi cette fonction ?", "1. Sauvegarder vos profils", "2. Restaurer vos profils",
        "Le son et l’avertissement de raid se déclenchent ensemble à 10 secondes. Les alertes nécessitent une vérification hors combat et sont ignorées en combat.",
        "Empêche certains identifiants de sorts de déclencher des alertes d’expiration.",
        "Ces options concernent la fenêtre de configuration ou les affichages partagés. La disposition et l’ordre des auras restent dans les pages Améliorations et Affaiblissements.",
    },
    esES = {
        "Anchura y altura de cada icono de aura, en píxeles.", "Espacio entre los iconos de una misma fila, en píxeles.",
        "Espacio entre filas, en píxeles.", "Número máximo de iconos antes de comenzar otra fila.",
        "Número máximo de filas mostradas en esta barra.", "Tamaño del texto de duración restante.",
        "Tamaño del número de acumulaciones.", "Dirección en la que los iconos llenan cada fila.",
        "Ordena las auras con el contenedor protegido de Blizzard. La posición de las auras permanentes debe comprobarse en el juego.",
        "Conserva la posición predeterminada de Blizzard o agrupa las auras permanentes conocidas en un lado. Las clasificaciones nuevas pueden actualizarse después del combate.",
        "Posición del texto de duración respecto al icono.", "Esquina usada para el número de acumulaciones.",
        "Grosor del contorno del tiempo y las acumulaciones.", " Arrastra el control o usa la rueda para avanzar de punto en punto.",
        " – valor exacto", " Escribe un número entero entre %d y %d y pulsa Intro.", " Haz clic para elegir una opción.",
        "Automático usa el idioma del cliente de WoW. Selecciona otro idioma para revisar su traducción y recarga la interfaz.",
        "Cada perfil guarda toda la configuración de ForeverBuffFrames. El perfil activo se guarda automáticamente. Los códigos de respaldo protegen todos los perfiles del problema actual de la beta.",
        "¿Por qué está esto aquí?", "1. Guardar los perfiles", "2. Restaurar los perfiles",
        "El sonido y el aviso de banda se activan juntos cuando quedan 10 segundos. Las alertas requieren una comprobación fuera de combate y se omiten durante el combate.",
        "Impide que ciertos ID de hechizo activen alertas de caducidad.",
        "Estas opciones afectan a la ventana de configuración o a elementos compartidos. El diseño y el orden de auras permanecen en las páginas Beneficios y Perjuicios.",
    },
    itIT = {
        "Larghezza e altezza di ogni icona, in pixel.", "Spazio tra le icone della stessa riga, in pixel.",
        "Spazio tra le righe, in pixel.", "Numero massimo di icone prima di iniziare una nuova riga.",
        "Numero massimo di righe mostrate nella barra.", "Dimensione del testo della durata restante.",
        "Dimensione del numero di accumuli.", "Direzione in cui le icone riempiono ogni riga.",
        "Ordina le aure con il contenitore protetto di Blizzard. Verifica in gioco la posizione delle aure permanenti.",
        "Mantiene la posizione predefinita di Blizzard o raggruppa le aure permanenti note su un lato. Le nuove classificazioni possono aggiornarsi dopo il combattimento.",
        "Posizione del testo della durata rispetto all’icona.", "Angolo usato per il numero di accumuli.",
        "Spessore del contorno del testo di durata e accumuli.", " Trascina il cursore o usa la rotellina per variazioni di un punto.",
        " – valore esatto", " Inserisci un numero intero da %d a %d e premi Invio.", " Fai clic per scegliere un’opzione.",
        "Automatico segue la lingua del client WoW. Seleziona un’altra lingua per verificarne la traduzione, poi ricarica l’interfaccia.",
        "Ogni profilo salva l’intera configurazione di ForeverBuffFrames. Il profilo attivo viene salvato automaticamente. I codici di backup proteggono tutti i profili dal problema attuale della beta.",
        "Perché è presente?", "1. Salva i profili", "2. Ripristina i profili",
        "Il suono e l’avviso incursione vengono attivati insieme a 10 secondi. Gli avvisi richiedono un controllo fuori dal combattimento e vengono ignorati durante il combattimento.",
        "Impedisce a specifici ID incantesimo di attivare avvisi di scadenza.",
        "Queste opzioni modificano la finestra delle impostazioni o gli elementi condivisi. Disposizione e ordine delle aure restano nelle pagine Benefici e Penalità.",
    },
    ptBR = {
        "Largura e altura de cada ícone de aura, em pixels.", "Espaço entre ícones na mesma linha, em pixels.",
        "Espaço entre linhas, em pixels.", "Número máximo de ícones antes de iniciar outra linha.",
        "Número máximo de linhas exibidas nesta barra.", "Tamanho do texto da duração restante.",
        "Tamanho do número de aplicações.", "Direção em que os ícones preenchem cada linha.",
        "Ordena as auras com o contêiner protegido da Blizzard. Confira no jogo a posição das auras permanentes.",
        "Mantém a posição padrão da Blizzard ou agrupa auras permanentes conhecidas em um lado. Novas classificações podem ser atualizadas após o combate.",
        "Posição do texto de duração em relação ao ícone.", "Canto usado para o número de aplicações.",
        "Espessura do contorno do tempo e das aplicações.", " Arraste o controle ou use a roda para alterar um ponto por vez.",
        " – valor exato", " Digite um número inteiro de %d a %d e pressione Enter.", " Clique para escolher uma opção.",
        "Automático segue o idioma do cliente WoW. Selecione outro idioma para revisar a tradução e recarregue a interface.",
        "Cada perfil guarda toda a configuração do ForeverBuffFrames. O perfil ativo é salvo automaticamente. Os códigos de backup protegem todos os perfis do problema atual da beta.",
        "Por que isto está aqui?", "1. Salve seus perfis", "2. Restaure seus perfis",
        "O som e o aviso de raide são acionados juntos quando faltam 10 segundos. Alertas exigem uma verificação fora de combate e são ignorados durante o combate.",
        "Impede que IDs específicos de feitiços acionem alertas de expiração.",
        "Estas opções afetam a janela de configurações ou elementos compartilhados. A disposição e a ordem das auras permanecem nas páginas Bônus e Penalidades.",
    },
    ruRU = {
        "Ширина и высота каждого значка эффекта в пикселях.", "Интервал между значками в одном ряду в пикселях.",
        "Интервал между рядами в пикселях.", "Максимальное число значков до перехода на новый ряд.",
        "Максимальное число рядов на этой панели.", "Размер текста оставшегося времени.",
        "Размер текста количества зарядов.", "Направление заполнения каждого ряда значками.",
        "Сортирует эффекты защищённым контейнером Blizzard. Размещение постоянных эффектов следует проверить в игре.",
        "Сохраняет стандартное размещение Blizzard или группирует известные постоянные эффекты с одной стороны. Новые данные обновляются после боя.",
        "Положение текста времени относительно значка.", "Угол для отображения числа зарядов.",
        "Толщина контура текста времени и зарядов.", " Перетащите ползунок или используйте колёсико для изменения на один пункт.",
        " — точное значение", " Введите целое число от %d до %d и нажмите Enter.", " Нажмите, чтобы выбрать вариант.",
        "Автоматический режим использует язык клиента WoW. Выберите другой язык для проверки перевода и перезагрузите интерфейс.",
        "Каждый профиль хранит все настройки ForeverBuffFrames. Активный профиль сохраняется автоматически. Коды резервной копии защищают профили от текущей ошибки бета-версии.",
        "Зачем это нужно?", "1. Сохраните профили", "2. Восстановите профили",
        "Звук и рейдовое предупреждение срабатывают вместе за 10 секунд. Для оповещений нужна проверка вне боя; в бою они пропускаются.",
        "Запрещает выбранным ID заклинаний вызывать предупреждения об окончании.",
        "Эти параметры относятся к окну настроек и общим элементам интерфейса. Размещение и порядок эффектов задаются на страницах положительных и отрицательных эффектов.",
    },
    koKR = {
        "각 효과 아이콘의 너비와 높이(픽셀)입니다.", "같은 줄의 아이콘 사이 간격(픽셀)입니다.",
        "줄 사이 간격(픽셀)입니다.", "다음 줄로 넘어가기 전 최대 아이콘 수입니다.",
        "이 바에 표시할 최대 줄 수입니다.", "남은 시간 글자의 크기입니다.",
        "중첩 수 글자의 크기입니다.", "아이콘이 각 줄을 채우는 방향입니다.",
        "블리자드의 보호된 컨테이너 정렬을 사용합니다. 영구 효과의 배치는 게임에서 확인해야 합니다.",
        "블리자드 기본 배치를 유지하거나 알려진 영구 효과를 한쪽에 모읍니다. 새로운 분류는 전투 후 갱신될 수 있습니다.",
        "아이콘을 기준으로 한 지속시간 글자의 위치입니다.", "중첩 수를 표시할 모서리입니다.",
        "시간 및 중첩 글자의 외곽선 두께입니다.", " 슬라이더를 끌거나 마우스 휠로 한 단계씩 조절합니다.",
        " — 정확한 값", " %d에서 %d 사이의 정수를 입력하고 Enter를 누르세요.", " 클릭하여 옵션을 선택하세요.",
        "자동은 WoW 클라이언트 언어를 따릅니다. 번역을 검토하려면 다른 언어를 선택한 뒤 인터페이스를 다시 불러오세요.",
        "각 프로필은 ForeverBuffFrames의 전체 설정을 저장합니다. 활성 프로필은 자동 저장됩니다. 백업 코드는 현재 베타 설정 문제로부터 모든 프로필을 보호합니다.",
        "왜 필요한가요?", "1. 프로필 저장", "2. 프로필 복원",
        "10초가 남으면 소리와 공격대 경보가 함께 실행됩니다. 실시간 알림은 비전투 중 효과 확인이 필요하며 전투 중에는 건너뜁니다.",
        "특정 강화 효과 주문 ID의 만료 알림을 차단합니다.",
        "이 설정은 설정 창과 공용 게임 표시에 적용됩니다. 바 배치와 효과 정렬은 강화 효과 및 약화 효과 페이지에서 설정합니다.",
    },
    zhCN = {
        "每个光环图标的宽度和高度（像素）。", "同一行图标之间的间距（像素）。", "各行之间的间距（像素）。",
        "开始新行前允许的最大图标数。", "此栏显示的最大行数。", "剩余时间文字大小。", "层数文字大小。",
        "图标填充每行的方向。", "使用暴雪受保护的容器排序。永久光环的位置需要在游戏中确认。",
        "保留暴雪默认位置，或将已知永久光环集中到一侧。新分类可在战斗结束后更新。",
        "持续时间文字相对于图标的位置。", "显示层数的角落。", "计时与层数文字的轮廓粗细。",
        " 拖动滑块或使用鼠标滚轮逐点调整。", " — 精确值", " 输入 %d 到 %d 之间的整数，然后按回车键。", " 点击选择选项。",
        "自动模式跟随 WoW 客户端语言。选择其他语言以检查翻译，然后重载界面。",
        "每个配置方案保存完整的 ForeverBuffFrames 设置。当前方案会自动保存。备份代码可保护所有方案免受当前测试版设置问题影响。",
        "为什么需要此功能？", "1. 保存配置方案", "2. 恢复配置方案",
        "剩余 10 秒时同时播放声音和团队警报。实时提醒需要在非战斗状态检查光环，战斗中会跳过。",
        "阻止指定增益法术 ID 触发到期提醒。", "这些选项影响设置窗口或共享游戏显示。栏位布局和光环排序仍在增益与减益页面中设置。",
    },
    zhTW = {
        "每個效果圖示的寬度與高度（像素）。", "同一列圖示之間的間距（像素）。", "各列之間的間距（像素）。",
        "開始新列前允許的最大圖示數。", "此列顯示的最大列數。", "剩餘時間文字大小。", "層數文字大小。",
        "圖示填滿每列的方向。", "使用暴雪受保護的容器排序。永久效果的位置需要在遊戲中確認。",
        "保留暴雪預設位置，或將已知永久效果集中到一側。新分類可在戰鬥結束後更新。",
        "持續時間文字相對於圖示的位置。", "顯示層數的角落。", "計時與層數文字的外框粗細。",
        " 拖曳滑桿或使用滑鼠滾輪逐點調整。", " — 精確值", " 輸入 %d 到 %d 之間的整數，然後按 Enter。", " 點擊以選擇選項。",
        "自動模式會跟隨 WoW 用戶端語言。選擇其他語言以檢查翻譯，然後重新載入介面。",
        "每個設定檔會儲存完整的 ForeverBuffFrames 設定。目前設定檔會自動儲存。備份代碼可保護所有設定檔免受目前測試版設定問題影響。",
        "為什麼需要此功能？", "1. 儲存設定檔", "2. 還原設定檔",
        "剩餘 10 秒時同時播放音效與團隊警告。即時提醒需要在非戰鬥狀態檢查效果，戰鬥中會略過。",
        "阻止指定增益效果法術 ID 觸發到期提醒。", "這些選項會影響設定視窗或共用遊戲顯示。列的版面與效果排序仍在增益及減益頁面中設定。",
    },
}
for locale, values in pairs(detailValues) do
    for index, key in ipairs(detailKeys) do translations[locale][key] = values[index] end
end
for index, key in ipairs(detailKeys) do translations.esMX[key] = detailValues.esES[index] end

local recoveryBodyKeys = {
    "The current WoW beta sometimes forgets addon settings after a reload or restart. Save a backup code outside the game now; paste it back here if your setup disappears. The addon cannot save a separate recovery file itself.",
    "Click Copy backup code below, press Ctrl+C, then paste it into Notepad and save the file. The code contains every named profile and the active-profile selection.",
    "Paste the code from your saved file into the box below and click Restore pasted code. New backup codes replace all profiles; older backup codes restore into the active profile.",
}
local recoveryBodyValues = {
    frFR = {
        "La bêta actuelle de WoW oublie parfois les paramètres des addons après un rechargement ou un redémarrage. Enregistrez un code de sauvegarde hors du jeu et recollez-le ici si votre configuration disparaît. L’addon ne peut pas créer lui-même un fichier de récupération séparé.",
        "Cliquez sur Copier le code de sauvegarde, appuyez sur Ctrl+C, puis collez le code dans le Bloc-notes et enregistrez le fichier. Le code contient tous les profils nommés et le profil actif.",
        "Collez le code de votre fichier ci-dessous et cliquez sur Restaurer le code collé. Les nouveaux codes remplacent tous les profils ; les anciens restaurent le profil actif.",
    },
    esES = {
        "La beta actual de WoW a veces olvida los ajustes de los addons después de recargar o reiniciar. Guarda un código de respaldo fuera del juego y vuelve a pegarlo aquí si desaparece tu configuración. El addon no puede crear por sí mismo un archivo de recuperación separado.",
        "Haz clic en Copiar código de respaldo, pulsa Ctrl+C, pega el código en el Bloc de notas y guarda el archivo. El código contiene todos los perfiles con nombre y la selección del perfil activo.",
        "Pega abajo el código del archivo guardado y haz clic en Restaurar código pegado. Los códigos nuevos sustituyen todos los perfiles; los antiguos restauran el perfil activo.",
    },
    itIT = {
        "La beta attuale di WoW a volte dimentica le impostazioni degli addon dopo un ricaricamento o un riavvio. Salva un codice di backup fuori dal gioco e incollalo qui se la configurazione scompare. L’addon non può creare autonomamente un file di ripristino separato.",
        "Fai clic su Copia codice backup, premi Ctrl+C, incolla il codice nel Blocco note e salva il file. Il codice contiene tutti i profili nominati e la selezione del profilo attivo.",
        "Incolla qui sotto il codice del file salvato e fai clic su Ripristina codice incollato. I nuovi codici sostituiscono tutti i profili; quelli precedenti ripristinano il profilo attivo.",
    },
    ptBR = {
        "A versão beta atual do WoW às vezes esquece as configurações dos addons após recarregar ou reiniciar. Salve um código de backup fora do jogo e cole-o aqui se sua configuração desaparecer. O addon não pode criar sozinho um arquivo de recuperação separado.",
        "Clique em Copiar código de backup, pressione Ctrl+C, cole o código no Bloco de Notas e salve o arquivo. O código contém todos os perfis nomeados e a seleção do perfil ativo.",
        "Cole abaixo o código do arquivo salvo e clique em Restaurar código colado. Códigos novos substituem todos os perfis; códigos antigos restauram o perfil ativo.",
    },
    ruRU = {
        "Текущая бета-версия WoW иногда забывает настройки аддонов после перезагрузки или перезапуска. Сохраните код резервной копии вне игры и вставьте его сюда, если настройки исчезнут. Аддон не может сам создать отдельный файл восстановления.",
        "Нажмите «Копировать код», нажмите Ctrl+C, вставьте код в Блокнот и сохраните файл. Код содержит все именованные профили и выбор активного профиля.",
        "Вставьте ниже код из сохранённого файла и нажмите «Восстановить код». Новые коды заменяют все профили; старые восстанавливают активный профиль.",
    },
    koKR = {
        "현재 WoW 베타는 다시 불러오거나 재시작한 뒤 애드온 설정을 잊는 경우가 있습니다. 게임 밖에 백업 코드를 저장하고 설정이 사라지면 여기에 붙여넣으세요. 애드온은 별도의 복구 파일을 직접 만들 수 없습니다.",
        "아래의 백업 코드 복사를 클릭하고 Ctrl+C를 누른 뒤 메모장에 붙여넣어 파일을 저장하세요. 코드에는 모든 프로필과 활성 프로필 선택이 포함됩니다.",
        "저장한 파일의 코드를 아래에 붙여넣고 붙여넣은 코드 복원을 클릭하세요. 새 백업 코드는 모든 프로필을 교체하며 이전 코드는 활성 프로필에 복원됩니다.",
    },
    zhCN = {
        "当前 WoW 测试版有时会在重载或重启后遗忘插件设置。请立即将备份代码保存在游戏之外；如果设置消失，可将其粘贴回此处。插件无法自行创建单独的恢复文件。",
        "点击下方的复制备份代码，按 Ctrl+C，然后粘贴到记事本并保存文件。代码包含所有命名配置方案和当前方案选择。",
        "将保存文件中的代码粘贴到下方，然后点击恢复粘贴的代码。新备份代码会替换所有配置方案；旧代码会恢复到当前方案。",
    },
    zhTW = {
        "目前的 WoW 測試版有時會在重新載入或重新啟動後遺忘插件設定。請立即將備份代碼儲存在遊戲之外；若設定消失，可將其貼回此處。插件無法自行建立獨立的還原檔案。",
        "點擊下方的複製備份代碼，按 Ctrl+C，然後貼到記事本並儲存檔案。代碼包含所有命名設定檔及目前設定檔選擇。",
        "將儲存檔案中的代碼貼到下方，然後點擊還原貼上的代碼。新備份代碼會取代所有設定檔；舊代碼會還原至目前設定檔。",
    },
}
for locale, values in pairs(recoveryBodyValues) do
    for index, key in ipairs(recoveryBodyKeys) do translations[locale][key] = values[index] end
end
for index, key in ipairs(recoveryBodyKeys) do translations.esMX[key] = recoveryBodyValues.esES[index] end

-- Messages shown outside the settings window: chat feedback, test mode,
-- combat restrictions, profile actions, and backup validation.
local runtimeKeys = {
    "Change settings after combat.", "Switch profiles after combat.", "Change language after combat.",
    "Reset after combat.", "Create profiles after combat.", "Copy profiles after combat.",
    "Rename profiles after combat.", "Delete profiles after combat.", "Restore settings after combat.",
    "Change the alert sound after combat.", "Change the alert blacklist after combat.",
    "Change Blizzard frames after combat.", "Change alert filters after combat.",
    "That profile no longer exists.", "At least one profile must remain.",
    "ForeverBuffFrames supports up to 50 profiles.", "Enter a positive numeric spell ID.",
    "Minimum buff duration must be a whole number from 0 to 3600 seconds.",
    "Test alert", "Test buff expires in 10 seconds", "Sample 10-second warning shown.",
    "Raid-warning display is unavailable in this client.", "Sample alert sound failed.", "Sample buff expired.",
    "click", "done", "created", "Change the lock after combat.", "Toggle test icons after combat.",
    "Bars unlocked; drag a bar or its label to move it.", "Bars locked.",
    "Test icons shown; /fbf test hides them.", "Test icons hidden.",
    "Change expiration sounds after combat.", "Test sound played.", "Alert sound is set to None.",
    "Test sound could not be played.", "10-second expiry alerts enabled.", "10-second expiry alerts disabled.",
    "Blizzard frame visibility will update after combat.", "Change layout after combat.", "Check status after combat.",
    "The client blocked an addon action; check the Lua error for details.",
    "Left click to open settings. Drag to move this minimap button.",
    "Enter a profile name.", "Profile names can use at most 32 characters.",
    "Profile names cannot contain control characters, semicolons, or equals signs.",
    "This is not a ForeverBuffFrames backup code.", "Invalid compact profile data.",
    "The backup contains duplicate profile names.", "Invalid profile count in backup.",
    "The backup's active profile is missing.", "Backup is missing the alert blacklist.", "Invalid alert blacklist.",
    "Older backup restored into the active profile.", "All profiles restored from backup.",
}
local runtimeValues = {
    deDE = {
        "Einstellungen nach dem Kampf ändern.", "Profile nach dem Kampf wechseln.", "Sprache nach dem Kampf ändern.", "Nach dem Kampf zurücksetzen.", "Profile nach dem Kampf erstellen.", "Profile nach dem Kampf kopieren.", "Profile nach dem Kampf umbenennen.", "Profile nach dem Kampf löschen.", "Einstellungen nach dem Kampf wiederherstellen.", "Warnton nach dem Kampf ändern.", "Warnungs-Blacklist nach dem Kampf ändern.", "Blizzard-Anzeigen nach dem Kampf ändern.", "Warnungsfilter nach dem Kampf ändern.", "Dieses Profil ist nicht mehr vorhanden.", "Mindestens ein Profil muss bestehen bleiben.", "ForeverBuffFrames unterstützt bis zu 50 Profile.", "Eine positive numerische Zauber-ID eingeben.", "Die Mindestdauer muss eine ganze Zahl von 0 bis 3600 Sekunden sein.", "Testwarnung", "Teststärkungszauber läuft in 10 Sekunden ab", "10-Sekunden-Testwarnung angezeigt.", "Die Schlachtzugswarnung ist in diesem Client nicht verfügbar.", "Testwarnton fehlgeschlagen.", "Teststärkungszauber abgelaufen.", "klick", "fertig", "erstellt", "Sperre nach dem Kampf ändern.", "Testsymbole nach dem Kampf umschalten.", "Leisten entsperrt; Leiste oder Beschriftung zum Verschieben ziehen.", "Leisten gesperrt.", "Testsymbole angezeigt; /fbf test blendet sie aus.", "Testsymbole ausgeblendet.", "Ablaufwarnungen nach dem Kampf ändern.", "Testton abgespielt.", "Warnton ist auf Keine gestellt.", "Testton konnte nicht abgespielt werden.", "10-Sekunden-Ablaufwarnungen aktiviert.", "10-Sekunden-Ablaufwarnungen deaktiviert.", "Blizzard-Anzeigen werden nach dem Kampf aktualisiert.", "Anordnung nach dem Kampf ändern.", "Status nach dem Kampf prüfen.", "Der Client hat eine Addon-Aktion blockiert; Lua-Fehler prüfen.", "Linksklick öffnet die Einstellungen. Ziehen verschiebt den Minikartenknopf.", "Profilnamen eingeben.", "Profilnamen dürfen höchstens 32 Zeichen enthalten.", "Profilnamen dürfen keine Steuerzeichen, Semikolons oder Gleichheitszeichen enthalten.", "Dies ist kein ForeverBuffFrames-Sicherungscode.", "Ungültige kompakte Profildaten.", "Die Sicherung enthält doppelte Profilnamen.", "Ungültige Profilanzahl in der Sicherung.", "Das aktive Profil der Sicherung fehlt.", "Der Sicherung fehlt die Warnungs-Blacklist.", "Ungültige Warnungs-Blacklist.", "Ältere Sicherung ins aktive Profil wiederhergestellt.", "Alle Profile aus der Sicherung wiederhergestellt.",
    },
    frFR = {
        "Modifiez les paramètres après le combat.", "Changez de profil après le combat.", "Changez de langue après le combat.", "Réinitialisez après le combat.", "Créez les profils après le combat.", "Copiez les profils après le combat.", "Renommez les profils après le combat.", "Supprimez les profils après le combat.", "Restaurez les paramètres après le combat.", "Changez le son après le combat.", "Modifiez la liste noire après le combat.", "Modifiez les cadres Blizzard après le combat.", "Modifiez les filtres après le combat.", "Ce profil n’existe plus.", "Au moins un profil doit rester.", "ForeverBuffFrames accepte jusqu’à 50 profils.", "Saisissez un ID de sort numérique positif.", "La durée minimale doit être un entier de 0 à 3600 secondes.", "Alerte de test", "L’amélioration de test expire dans 10 secondes", "Alerte de test à 10 secondes affichée.", "L’avertissement de raid est indisponible sur ce client.", "Échec du son d’alerte de test.", "L’amélioration de test a expiré.", "cliquer", "terminé", "créé", "Changez le verrouillage après le combat.", "Basculez les icônes de test après le combat.", "Barres déverrouillées ; faites glisser une barre ou son étiquette.", "Barres verrouillées.", "Icônes de test affichées ; /fbf test les masque.", "Icônes de test masquées.", "Modifiez les alertes après le combat.", "Son de test joué.", "Le son d’alerte est réglé sur Aucun.", "Impossible de jouer le son de test.", "Alertes à 10 secondes activées.", "Alertes à 10 secondes désactivées.", "Les cadres Blizzard seront actualisés après le combat.", "Modifiez la disposition après le combat.", "Vérifiez l’état après le combat.", "Le client a bloqué une action de l’addon ; consultez l’erreur Lua.", "Clic gauche : paramètres. Faites glisser pour déplacer ce bouton.", "Saisissez un nom de profil.", "Un nom de profil peut contenir 32 caractères au maximum.", "Les noms ne peuvent contenir ni caractères de contrôle, ni points-virgules, ni signes égal.", "Ce code n’est pas une sauvegarde ForeverBuffFrames.", "Données compactes de profil invalides.", "La sauvegarde contient des noms de profil en double.", "Nombre de profils invalide dans la sauvegarde.", "Le profil actif de la sauvegarde est absent.", "La liste noire manque dans la sauvegarde.", "Liste noire invalide.", "Ancienne sauvegarde restaurée dans le profil actif.", "Tous les profils ont été restaurés.",
    },
    esES = {
        "Cambia los ajustes después del combate.", "Cambia de perfil después del combate.", "Cambia el idioma después del combate.", "Restablece después del combate.", "Crea perfiles después del combate.", "Copia perfiles después del combate.", "Renombra perfiles después del combate.", "Elimina perfiles después del combate.", "Restaura los ajustes después del combate.", "Cambia el sonido después del combate.", "Cambia la lista negra después del combate.", "Cambia los marcos de Blizzard después del combate.", "Cambia los filtros después del combate.", "Ese perfil ya no existe.", "Debe quedar al menos un perfil.", "ForeverBuffFrames admite hasta 50 perfiles.", "Introduce un ID de hechizo numérico positivo.", "La duración mínima debe ser un entero entre 0 y 3600 segundos.", "Alerta de prueba", "El beneficio de prueba caduca en 10 segundos", "Aviso de prueba de 10 segundos mostrado.", "El aviso de banda no está disponible en este cliente.", "Falló el sonido de prueba.", "El beneficio de prueba ha caducado.", "clic", "fin", "creado", "Cambia el bloqueo después del combate.", "Alterna los iconos de prueba después del combate.", "Barras desbloqueadas; arrastra una barra o su etiqueta.", "Barras bloqueadas.", "Iconos de prueba visibles; /fbf test los oculta.", "Iconos de prueba ocultos.", "Cambia las alertas después del combate.", "Sonido de prueba reproducido.", "El sonido de alerta está en Ninguno.", "No se pudo reproducir el sonido de prueba.", "Alertas de 10 segundos activadas.", "Alertas de 10 segundos desactivadas.", "Los marcos de Blizzard se actualizarán después del combate.", "Cambia el diseño después del combate.", "Comprueba el estado después del combate.", "El cliente bloqueó una acción del addon; revisa el error Lua.", "Clic izquierdo para abrir ajustes. Arrastra para mover este botón.", "Introduce un nombre de perfil.", "Los nombres de perfil admiten hasta 32 caracteres.", "Los nombres no pueden contener caracteres de control, punto y coma ni signos igual.", "Este no es un código de respaldo de ForeverBuffFrames.", "Datos compactos de perfil no válidos.", "El respaldo contiene nombres de perfil duplicados.", "Cantidad de perfiles no válida en el respaldo.", "Falta el perfil activo del respaldo.", "Falta la lista negra en el respaldo.", "Lista negra no válida.", "Respaldo antiguo restaurado en el perfil activo.", "Todos los perfiles se restauraron desde el respaldo.",
    },
}

-- Continue the runtime catalogue separately so each row stays easy to audit.
local moreRuntimeValues = {
    itIT = {
        "Modifica le impostazioni dopo il combattimento.", "Cambia profilo dopo il combattimento.", "Cambia lingua dopo il combattimento.", "Reimposta dopo il combattimento.", "Crea i profili dopo il combattimento.", "Copia i profili dopo il combattimento.", "Rinomina i profili dopo il combattimento.", "Elimina i profili dopo il combattimento.", "Ripristina le impostazioni dopo il combattimento.", "Cambia il suono dopo il combattimento.", "Modifica la lista nera dopo il combattimento.", "Modifica i riquadri Blizzard dopo il combattimento.", "Modifica i filtri dopo il combattimento.", "Quel profilo non esiste più.", "Deve rimanere almeno un profilo.", "ForeverBuffFrames supporta fino a 50 profili.", "Inserisci un ID incantesimo numerico positivo.", "La durata minima deve essere un numero intero da 0 a 3600 secondi.", "Avviso di prova", "Il beneficio di prova scade tra 10 secondi", "Avviso di prova a 10 secondi mostrato.", "L’avviso incursione non è disponibile in questo client.", "Riproduzione del suono di prova non riuscita.", "Il beneficio di prova è scaduto.", "clic", "fine", "creato", "Cambia il blocco dopo il combattimento.", "Mostra o nascondi le icone di prova dopo il combattimento.", "Barre sbloccate; trascina una barra o la sua etichetta.", "Barre bloccate.", "Icone di prova visibili; /fbf test le nasconde.", "Icone di prova nascoste.", "Modifica gli avvisi dopo il combattimento.", "Suono di prova riprodotto.", "Il suono di avviso è impostato su Nessuno.", "Impossibile riprodurre il suono di prova.", "Avvisi a 10 secondi attivati.", "Avvisi a 10 secondi disattivati.", "I riquadri Blizzard verranno aggiornati dopo il combattimento.", "Modifica la disposizione dopo il combattimento.", "Controlla lo stato dopo il combattimento.", "Il client ha bloccato un’azione dell’addon; controlla l’errore Lua.", "Clic sinistro per aprire le impostazioni. Trascina per spostare il pulsante.", "Inserisci un nome per il profilo.", "I nomi dei profili possono contenere al massimo 32 caratteri.", "I nomi non possono contenere caratteri di controllo, punti e virgola o segni di uguale.", "Questo non è un codice di backup di ForeverBuffFrames.", "Dati compatti del profilo non validi.", "Il backup contiene nomi di profilo duplicati.", "Numero di profili non valido nel backup.", "Il profilo attivo del backup è mancante.", "Nel backup manca la lista nera degli avvisi.", "Lista nera degli avvisi non valida.", "Backup precedente ripristinato nel profilo attivo.", "Tutti i profili sono stati ripristinati dal backup.",
    },
    ptBR = {
        "Altere as configurações após o combate.", "Troque de perfil após o combate.", "Altere o idioma após o combate.", "Redefina após o combate.", "Crie perfis após o combate.", "Copie perfis após o combate.", "Renomeie perfis após o combate.", "Exclua perfis após o combate.", "Restaure as configurações após o combate.", "Altere o som após o combate.", "Altere a lista de bloqueio após o combate.", "Altere os quadros da Blizzard após o combate.", "Altere os filtros após o combate.", "Esse perfil não existe mais.", "É necessário manter pelo menos um perfil.", "ForeverBuffFrames aceita até 50 perfis.", "Digite um ID numérico de feitiço positivo.", "A duração mínima deve ser um número inteiro de 0 a 3600 segundos.", "Alerta de teste", "O bônus de teste expira em 10 segundos", "Aviso de teste de 10 segundos exibido.", "O aviso de raide não está disponível neste cliente.", "Falha ao tocar o som de teste.", "O bônus de teste expirou.", "clique", "fim", "criado", "Altere o bloqueio após o combate.", "Alterne os ícones de teste após o combate.", "Barras desbloqueadas; arraste uma barra ou seu rótulo.", "Barras bloqueadas.", "Ícones de teste exibidos; /fbf test os oculta.", "Ícones de teste ocultos.", "Altere os alertas após o combate.", "Som de teste reproduzido.", "O som de alerta está definido como Nenhum.", "Não foi possível reproduzir o som de teste.", "Alertas de 10 segundos ativados.", "Alertas de 10 segundos desativados.", "Os quadros da Blizzard serão atualizados após o combate.", "Altere a disposição após o combate.", "Verifique o estado após o combate.", "O cliente bloqueou uma ação do addon; verifique o erro Lua.", "Clique esquerdo para abrir as configurações. Arraste para mover este botão.", "Digite um nome de perfil.", "Os nomes de perfil podem ter no máximo 32 caracteres.", "Os nomes não podem conter caracteres de controle, ponto e vírgula ou sinais de igual.", "Este não é um código de backup do ForeverBuffFrames.", "Dados compactos de perfil inválidos.", "O backup contém nomes de perfil duplicados.", "Quantidade de perfis inválida no backup.", "O perfil ativo do backup está ausente.", "A lista de bloqueio de alertas está ausente no backup.", "Lista de bloqueio de alertas inválida.", "Backup antigo restaurado no perfil ativo.", "Todos os perfis foram restaurados do backup.",
    },
}
for locale, values in pairs(moreRuntimeValues) do runtimeValues[locale] = values end
local asianRuntimeValues = {
    ruRU = {
        "Измените настройки после боя.", "Смените профиль после боя.", "Смените язык после боя.", "Выполните сброс после боя.", "Создайте профили после боя.", "Копируйте профили после боя.", "Переименуйте профили после боя.", "Удалите профили после боя.", "Восстановите настройки после боя.", "Измените звук после боя.", "Измените чёрный список после боя.", "Измените панели Blizzard после боя.", "Измените фильтры после боя.", "Этот профиль больше не существует.", "Должен остаться хотя бы один профиль.", "Поддерживается до 50 профилей.", "Введите положительный числовой ID заклинания.", "Минимальная длительность должна быть целым числом от 0 до 3600.", "Тестовое оповещение", "Тестовый эффект исчезнет через 10 секунд", "Тестовое предупреждение показано.", "Предупреждение рейда недоступно.", "Не удалось воспроизвести тестовый звук.", "Тестовый эффект закончился.", "нажать", "готово", "создано", "Измените блокировку после боя.", "Переключите тестовые значки после боя.", "Панели разблокированы; перетащите панель или заголовок.", "Панели заблокированы.", "Тестовые значки показаны; /fbf test скрывает их.", "Тестовые значки скрыты.", "Измените оповещения после боя.", "Тестовый звук воспроизведён.", "Звук оповещения установлен на Нет.", "Не удалось воспроизвести тестовый звук.", "Оповещения за 10 секунд включены.", "Оповещения за 10 секунд выключены.", "Панели Blizzard обновятся после боя.", "Измените расположение после боя.", "Проверьте состояние после боя.", "Клиент заблокировал действие аддона; проверьте ошибку Lua.", "Левая кнопка открывает настройки. Перетащите кнопку для перемещения.", "Введите имя профиля.", "Имя профиля может содержать не более 32 символов.", "Имя не может содержать управляющие символы, точки с запятой и знаки равенства.", "Это не код резервной копии ForeverBuffFrames.", "Недопустимые данные профиля.", "В копии есть повторяющиеся имена профилей.", "Недопустимое число профилей в копии.", "Активный профиль копии отсутствует.", "В копии отсутствует чёрный список.", "Недопустимый чёрный список.", "Старая копия восстановлена в активный профиль.", "Все профили восстановлены из копии.",
    },
    koKR = {
        "전투가 끝난 뒤 설정을 변경하세요.", "전투가 끝난 뒤 프로필을 전환하세요.", "전투가 끝난 뒤 언어를 변경하세요.", "전투가 끝난 뒤 초기화하세요.", "전투가 끝난 뒤 프로필을 만드세요.", "전투가 끝난 뒤 프로필을 복사하세요.", "전투가 끝난 뒤 프로필 이름을 바꾸세요.", "전투가 끝난 뒤 프로필을 삭제하세요.", "전투가 끝난 뒤 설정을 복원하세요.", "전투가 끝난 뒤 소리를 변경하세요.", "전투가 끝난 뒤 차단 목록을 변경하세요.", "전투가 끝난 뒤 Blizzard 창을 변경하세요.", "전투가 끝난 뒤 필터를 변경하세요.", "해당 프로필이 더 이상 없습니다.", "프로필을 하나 이상 남겨야 합니다.", "프로필은 최대 50개까지 지원됩니다.", "양의 숫자 주문 ID를 입력하세요.", "최소 지속시간은 0~3600의 정수여야 합니다.", "테스트 알림", "테스트 강화 효과가 10초 후 만료됩니다", "10초 테스트 경고를 표시했습니다.", "이 클라이언트에서는 공격대 경고를 사용할 수 없습니다.", "테스트 알림 소리를 재생하지 못했습니다.", "테스트 강화 효과가 만료되었습니다.", "클릭", "완료", "생성됨", "전투가 끝난 뒤 잠금을 변경하세요.", "전투가 끝난 뒤 테스트 아이콘을 전환하세요.", "바 잠금 해제됨; 바 또는 제목을 끌어 이동하세요.", "바 잠금됨.", "테스트 아이콘 표시됨; /fbf test로 숨깁니다.", "테스트 아이콘 숨김.", "전투가 끝난 뒤 만료 알림을 변경하세요.", "테스트 소리를 재생했습니다.", "알림 소리가 없음으로 설정되어 있습니다.", "테스트 소리를 재생하지 못했습니다.", "10초 만료 알림을 켰습니다.", "10초 만료 알림을 껐습니다.", "전투가 끝난 뒤 Blizzard 창이 갱신됩니다.", "전투가 끝난 뒤 배치를 변경하세요.", "전투가 끝난 뒤 상태를 확인하세요.", "클라이언트가 애드온 동작을 차단했습니다. Lua 오류를 확인하세요.", "왼쪽 클릭으로 설정을 엽니다. 끌어서 버튼을 이동합니다.", "프로필 이름을 입력하세요.", "프로필 이름은 최대 32자까지 사용할 수 있습니다.", "프로필 이름에 제어 문자, 세미콜론 또는 등호를 사용할 수 없습니다.", "ForeverBuffFrames 백업 코드가 아닙니다.", "압축 프로필 데이터가 잘못되었습니다.", "백업에 중복된 프로필 이름이 있습니다.", "백업의 프로필 수가 잘못되었습니다.", "백업의 활성 프로필이 없습니다.", "백업에 알림 차단 목록이 없습니다.", "알림 차단 목록이 잘못되었습니다.", "이전 백업을 활성 프로필에 복원했습니다.", "백업에서 모든 프로필을 복원했습니다.",
    },
    zhCN = {
        "请在战斗结束后更改设置。", "请在战斗结束后切换配置方案。", "请在战斗结束后更改语言。", "请在战斗结束后重置。", "请在战斗结束后创建配置方案。", "请在战斗结束后复制配置方案。", "请在战斗结束后重命名配置方案。", "请在战斗结束后删除配置方案。", "请在战斗结束后恢复设置。", "请在战斗结束后更改音效。", "请在战斗结束后更改黑名单。", "请在战斗结束后更改暴雪框体。", "请在战斗结束后更改过滤条件。", "该配置方案已不存在。", "必须保留至少一个配置方案。", "最多支持 50 个配置方案。", "请输入正数法术 ID。", "最短持续时间必须是 0 至 3600 的整数。", "测试提醒", "测试增益将在 10 秒后到期", "已显示 10 秒测试警告。", "此客户端无法显示团队警告。", "测试提醒音效播放失败。", "测试增益已到期。", "点击", "完成", "已创建", "请在战斗结束后更改锁定状态。", "请在战斗结束后切换测试图标。", "栏已解锁；拖动栏或标题即可移动。", "栏已锁定。", "已显示测试图标；输入 /fbf test 可隐藏。", "已隐藏测试图标。", "请在战斗结束后更改到期提醒。", "已播放测试音效。", "提醒音效已设为无。", "无法播放测试音效。", "已启用提前 10 秒提醒。", "已禁用提前 10 秒提醒。", "暴雪框体将在战斗结束后更新。", "请在战斗结束后更改布局。", "请在战斗结束后检查状态。", "客户端阻止了一项插件操作；请查看 Lua 错误。", "左键点击打开设置。拖动可移动此按钮。", "请输入配置方案名称。", "配置方案名称最多可使用 32 个字符。", "名称不能包含控制字符、分号或等号。", "这不是 ForeverBuffFrames 备份代码。", "压缩配置方案数据无效。", "备份包含重复的配置方案名称。", "备份中的配置方案数量无效。", "备份中的当前配置方案缺失。", "备份中缺少提醒黑名单。", "提醒黑名单无效。", "旧版备份已恢复到当前配置方案。", "已从备份恢复所有配置方案。",
    },
    zhTW = {
        "請在戰鬥結束後變更設定。", "請在戰鬥結束後切換設定檔。", "請在戰鬥結束後變更語言。", "請在戰鬥結束後重設。", "請在戰鬥結束後建立設定檔。", "請在戰鬥結束後複製設定檔。", "請在戰鬥結束後重新命名設定檔。", "請在戰鬥結束後刪除設定檔。", "請在戰鬥結束後還原設定。", "請在戰鬥結束後變更音效。", "請在戰鬥結束後變更黑名單。", "請在戰鬥結束後變更暴雪框架。", "請在戰鬥結束後變更篩選條件。", "該設定檔已不存在。", "必須保留至少一個設定檔。", "最多支援 50 個設定檔。", "請輸入正數法術 ID。", "最短持續時間必須是 0 至 3600 的整數。", "測試提醒", "測試增益效果將在 10 秒後到期", "已顯示 10 秒測試警告。", "此用戶端無法顯示團隊警告。", "測試提醒音效播放失敗。", "測試增益效果已到期。", "點擊", "完成", "已建立", "請在戰鬥結束後變更鎖定狀態。", "請在戰鬥結束後切換測試圖示。", "列已解鎖；拖曳列或標題即可移動。", "列已鎖定。", "已顯示測試圖示；輸入 /fbf test 可隱藏。", "已隱藏測試圖示。", "請在戰鬥結束後變更到期提醒。", "已播放測試音效。", "提醒音效已設為無。", "無法播放測試音效。", "已啟用提前 10 秒提醒。", "已停用提前 10 秒提醒。", "暴雪框架將在戰鬥結束後更新。", "請在戰鬥結束後變更版面。", "請在戰鬥結束後檢查狀態。", "用戶端阻止了一項插件操作；請查看 Lua 錯誤。", "左鍵點擊開啟設定。拖曳可移動此按鈕。", "請輸入設定檔名稱。", "設定檔名稱最多可使用 32 個字元。", "名稱不能包含控制字元、分號或等號。", "這不是 ForeverBuffFrames 備份代碼。", "壓縮設定檔資料無效。", "備份包含重複的設定檔名稱。", "備份中的設定檔數量無效。", "備份中的目前設定檔遺失。", "備份中缺少提醒黑名單。", "提醒黑名單無效。", "舊版備份已還原至目前設定檔。", "已從備份還原所有設定檔。",
    },
}
for locale, values in pairs(asianRuntimeValues) do runtimeValues[locale] = values end
runtimeValues.esMX = runtimeValues.esES
for locale, values in pairs(runtimeValues) do
    for index, key in ipairs(runtimeKeys) do translations[locale][key] = values[index] end
end

translations.deDE["This cannot be undone."] = "Dies kann nicht rückgängig gemacht werden."
translations.esES["This cannot be undone."] = "Esta acción no se puede deshacer."
translations.esMX["This cannot be undone."] = translations.esES["This cannot be undone."]
translations.frFR["This cannot be undone."] = "Cette action est irréversible."
translations.itIT["This cannot be undone."] = "Questa azione non può essere annullata."
translations.koKR["This cannot be undone."] = "이 작업은 되돌릴 수 없습니다."
translations.ptBR["This cannot be undone."] = "Esta ação não pode ser desfeita."
translations.ruRU["This cannot be undone."] = "Это действие нельзя отменить."
translations.zhCN["This cannot be undone."] = "此操作无法撤销。"
translations.zhTW["This cannot be undone."] = "此操作無法復原。"

local selected = "auto"
local active = GetLocale and GetLocale() or "enUS"

function Locale.Initialize(value)
    selected = supported[value] and value or "auto"
    active = selected == "auto" and (GetLocale and GetLocale() or "enUS") or selected
    if not supported[active] then active = "enUS" end
end

function Locale.IsSupported(value) return supported[value] == true end
function Locale.GetSelected() return selected end
function Locale.GetActive() return active end
function Locale.GetClient() return GetLocale and GetLocale() or "enUS" end

local localeFonts = {
    ruRU = "Fonts\\FRIZQT___CYR.TTF",
    koKR = "Fonts\\2002.TTF",
    zhCN = "Fonts\\ARKai_T.TTF",
    zhTW = "Fonts\\bLEI00D.TTF",
}

function Locale.FontPath(code) return localeFonts[code or active] end

function Locale.Name(code)
    for _, entry in ipairs(Locale.supported) do
        if entry[1] == code then return entry[2] end
    end
    return code
end

local quietBuffNames = {
    enUS = { "eating", "drinking", "food", "drink", "refreshment" },
    deDE = { "essen", "trinken", "nahrung", "getränk", "erfrischung" },
    esES = { "comiendo", "bebiendo", "comida", "bebida", "refrigerio" },
    esMX = { "comiendo", "bebiendo", "comida", "bebida", "refrigerio" },
    frFR = { "manger", "boire", "nourriture", "boisson", "rafraîchissement" },
    itIT = { "mangiare", "bere", "cibo", "bevanda", "ristoro" },
    koKR = { "음식 먹기", "음료 마시기", "음식", "음료", "원기 회복" },
    ptBR = { "comendo", "bebendo", "comida", "bebida", "refresco" },
    ruRU = { "еда", "питье", "пища", "напиток", "подкрепление" },
    zhCN = { "进食", "喝水", "食物", "饮料", "点心" },
    zhTW = { "進食", "喝水", "食物", "飲料", "點心" },
}

function Locale.QuietBuffNames()
    local result = {}
    local names = quietBuffNames[Locale.GetClient()] or quietBuffNames.enUS
    for _, name in ipairs(names) do result[name:lower()] = true end
    return result
end

function FBF.L(text, ...)
    local value = translations[active] and translations[active][text] or text
    if select("#", ...) > 0 then return value:format(...) end
    return value
end

Locale.Initialize(type(ForeverBuffFramesDB) == "table" and ForeverBuffFramesDB.uiLocale or "auto")
