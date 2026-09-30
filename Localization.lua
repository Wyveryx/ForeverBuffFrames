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

local resolvedSettingsProfileKey = "Each profile stores the complete ForeverBuffFrames setup. The active profile is saved automatically. Backup codes remain available in case the earlier beta settings problem returns."
local resolvedSettingsRecoveryKey = "Earlier WoW Forever beta builds sometimes forgot addon settings after a reload or restart. That issue currently appears resolved, but you can keep a backup code outside the game in case it returns. The addon cannot save a separate recovery file itself."
local resolvedSettingsTranslations = {
    deDE = { "Jedes Profil speichert die vollständige ForeverBuffFrames-Konfiguration. Das aktive Profil wird automatisch gespeichert. Sicherungscodes bleiben verfügbar, falls das frühere Beta-Einstellungsproblem zurückkehrt.", "Frühere WoW-Forever-Betaversionen vergaßen nach einem Neuladen oder Neustart manchmal Addon-Einstellungen. Das Problem scheint derzeit behoben zu sein, aber du kannst einen Sicherungscode außerhalb des Spiels aufbewahren, falls es zurückkehrt. Das Addon kann selbst keine separate Wiederherstellungsdatei speichern." },
    frFR = { "Chaque profil conserve toute la configuration de ForeverBuffFrames. Le profil actif est enregistré automatiquement. Les codes de sauvegarde restent disponibles au cas où l’ancien problème de paramètres de la bêta réapparaîtrait.", "Les anciennes versions bêta de WoW Forever oubliaient parfois les paramètres des addons après un rechargement ou un redémarrage. Ce problème semble actuellement résolu, mais vous pouvez conserver un code de sauvegarde hors du jeu au cas où il réapparaîtrait. L’addon ne peut pas créer lui-même un fichier de récupération séparé." },
    esES = { "Cada perfil guarda toda la configuración de ForeverBuffFrames. El perfil activo se guarda automáticamente. Los códigos de respaldo siguen disponibles por si vuelve el anterior problema de ajustes de la beta.", "Las versiones beta anteriores de WoW Forever a veces olvidaban los ajustes de los addons después de recargar o reiniciar. El problema parece resuelto actualmente, pero puedes guardar un código de respaldo fuera del juego por si vuelve. El addon no puede crear por sí mismo un archivo de recuperación separado." },
    itIT = { "Ogni profilo conserva l’intera configurazione di ForeverBuffFrames. Il profilo attivo viene salvato automaticamente. I codici di backup restano disponibili nel caso ritorni il precedente problema delle impostazioni beta.", "Le versioni beta precedenti di WoW Forever a volte dimenticavano le impostazioni degli addon dopo un ricaricamento o riavvio. Il problema sembra attualmente risolto, ma puoi conservare un codice di backup fuori dal gioco nel caso ritorni. L’addon non può creare autonomamente un file di ripristino separato." },
    ptBR = { "Cada perfil armazena toda a configuração do ForeverBuffFrames. O perfil ativo é salvo automaticamente. Os códigos de backup continuam disponíveis caso o antigo problema das configurações beta retorne.", "Versões beta anteriores do WoW Forever às vezes esqueciam as configurações dos addons após recarregar ou reiniciar. O problema parece resolvido no momento, mas você pode guardar um código de backup fora do jogo caso ele retorne. O addon não pode criar sozinho um arquivo de recuperação separado." },
    ruRU = { "Каждый профиль хранит полную настройку ForeverBuffFrames. Активный профиль сохраняется автоматически. Коды резервной копии остаются доступными на случай возврата прежней проблемы бета-версии с настройками.", "В ранних бета-версиях WoW Forever настройки аддонов иногда пропадали после перезагрузки или перезапуска. Сейчас проблема, похоже, решена, но можно сохранить код резервной копии вне игры на случай её возвращения. Аддон не может сам создать отдельный файл восстановления." },
    koKR = { "각 프로필에는 ForeverBuffFrames의 전체 설정이 저장되며 활성 프로필은 자동으로 저장됩니다. 이전 베타 설정 문제가 다시 발생할 경우를 대비해 백업 코드를 계속 사용할 수 있습니다.", "이전 WoW Forever 베타 빌드에서는 다시 불러오거나 재시작한 뒤 애드온 설정이 사라지는 경우가 있었습니다. 현재는 해결된 것으로 보이지만 문제가 다시 발생할 경우를 대비해 게임 밖에 백업 코드를 보관할 수 있습니다. 애드온은 별도의 복구 파일을 직접 만들 수 없습니다." },
    zhCN = { "每个配置方案都会保存完整的 ForeverBuffFrames 设置，当前方案会自动保存。备份代码仍然可用，以防早期测试版的设置问题再次出现。", "早期 WoW Forever 测试版有时会在重载或重启后遗忘插件设置。目前该问题似乎已解决，但仍可在游戏外保存备份代码，以防问题再次出现。插件无法自行创建单独的恢复文件。" },
    zhTW = { "每個設定檔都會儲存完整的 ForeverBuffFrames 設定，目前設定檔會自動儲存。備份代碼仍然可用，以防早期測試版的設定問題再次出現。", "早期 WoW Forever 測試版有時會在重新載入或重新啟動後遺忘插件設定。目前該問題似乎已解決，但仍可在遊戲外保存備份代碼，以防問題再次出現。插件無法自行建立獨立的還原檔案。" },
}
resolvedSettingsTranslations.esMX = resolvedSettingsTranslations.esES
for locale, values in pairs(resolvedSettingsTranslations) do
    translations[locale][resolvedSettingsProfileKey] = values[1]
    translations[locale][resolvedSettingsRecoveryKey] = values[2]
end

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

local diagnosticKeys = {
    "Diagnostics", "Preview existing effects and collect a compact support report.",
    "Preview existing effects and copy a compact report for support. Opening this tab does not change gameplay settings.",
    "Test Lab", "These previews use the addon's current test icons and alert sound. Combat-safe feature probes will be added in their own phases.",
    "System Status", "Client", "Interface", "Aura data restricted", "Aura containers",
    "Native dispel styling", "Typed aura filters", "Combat-safe aura sounds", "Tracking API",
    "Last blocked operation", "Available", "Unavailable", "Yes", "No", "Recheck capabilities",
    "Clear blocked action", "Copy diagnostic report", "Rescan expiry alerts", "Rescan expiry alerts after combat.",
    "Show experimental tools", "Experimental controls are intentionally empty in Phase 10. Later phases will add explicit border, sound, tracking, and duration probes here.",
    "Reveal opt-in development probes. They never run merely because this tab is opened.", "Unknown operation",
    "Read the current combat, aura, sound, tracking, and blocked-action status again.",
    "Forget the last ADDON_ACTION_BLOCKED event recorded for this session. This does not hide Lua errors.",
    "Scan current buffs again and schedule eligible ten-second expiry alerts. This does not play a test sound.",
}
local diagnosticValues = {
    deDE = {
        "Diagnose", "Vorhandene Effekte testen und einen kompakten Supportbericht erstellen.",
        "Vorhandene Effekte testen und einen kompakten Supportbericht kopieren. Das Öffnen dieses Tabs ändert keine Spieleinstellungen.",
        "Testlabor", "Diese Vorschauen verwenden die aktuellen Testsymbole und den Warnton des Addons. Kampfsichere Funktionstests folgen in eigenen Phasen.",
        "Systemstatus", "Client", "Interface", "Aurdaten eingeschränkt", "Aurcontainer", "Native Bannstil-Anzeige", "Typisierte Aurafilter", "Kampfsichere Auratöne", "Ortungs-API", "Letzte blockierte Aktion",
        "Verfügbar", "Nicht verfügbar", "Ja", "Nein", "Status aktualisieren", "Letzten Fehler löschen", "Diagnosebericht kopieren", "Warneinrichtung erneut versuchen", "Versuche die Warneinrichtung nach dem Kampf erneut.",
        "Experimentelle Werkzeuge anzeigen", "Die experimentellen Bedienelemente sind in Phase 10 absichtlich leer. Spätere Phasen ergänzen hier ausdrückliche Tests für Rahmen, Töne, Ortung und Dauer.",
        "Blendet optionale Entwicklungstests ein. Sie starten niemals nur durch das Öffnen dieses Tabs.", "Unbekannte Aktion",
        "Liest den aktuellen Kampf-, Aura-, Ton-, Ortungs- und Blockierungsstatus erneut ein.", "Vergisst das letzte ADDON_ACTION_BLOCKED-Ereignis dieser Sitzung. Lua-Fehler werden dadurch nicht ausgeblendet.", "Prüft aktuelle Stärkungszauber erneut und plant geeignete Warnungen zehn Sekunden vor Ablauf. Dabei wird kein Testton abgespielt.",
    },
    esES = {
        "Diagnóstico", "Prueba los efectos existentes y genera un informe compacto para soporte.",
        "Prueba los efectos existentes y copia un informe compacto para soporte. Abrir esta pestaña no cambia la configuración de juego.",
        "Laboratorio de pruebas", "Estas vistas previas usan los iconos de prueba y el sonido de alerta actuales del addon. Las pruebas seguras en combate llegarán en sus propias fases.",
        "Estado del sistema", "Cliente", "Interfaz", "Datos de auras restringidos", "Contenedores de auras", "Estilo nativo de disipación", "Filtros de aura por tipo", "Sonidos de aura seguros en combate", "API de seguimiento", "Última operación bloqueada",
        "Disponible", "No disponible", "Sí", "No", "Actualizar estado", "Borrar último error", "Copiar informe de diagnóstico", "Reintentar configuración de alertas", "Reintenta la configuración de alertas después del combate.",
        "Mostrar herramientas experimentales", "Los controles experimentales están vacíos intencionadamente en la fase 10. Las fases posteriores añadirán aquí pruebas explícitas de bordes, sonidos, seguimiento y duración.",
        "Muestra pruebas de desarrollo opcionales. Nunca se ejecutan solo por abrir esta pestaña.", "Operación desconocida",
        "Vuelve a leer el estado actual de combate, auras, sonido, seguimiento y acciones bloqueadas.", "Olvida el último evento ADDON_ACTION_BLOCKED registrado en esta sesión. No oculta los errores de Lua.", "Vuelve a analizar los beneficios actuales y programa las alertas válidas a diez segundos de expirar. No reproduce un sonido de prueba.",
    },
    frFR = {
        "Diagnostic", "Testez les effets existants et créez un rapport d'assistance compact.",
        "Testez les effets existants et copiez un rapport d'assistance compact. Ouvrir cet onglet ne modifie aucun réglage de jeu.",
        "Laboratoire de test", "Ces aperçus utilisent les icônes de test et le son d'alerte actuels de l'addon. Les tests compatibles avec le combat seront ajoutés dans leurs propres phases.",
        "État du système", "Client", "Interface", "Données d'aura restreintes", "Conteneurs d'auras", "Style natif de dissipation", "Filtres d'aura typés", "Sons d'aura compatibles avec le combat", "API de pistage", "Dernière opération bloquée",
        "Disponible", "Indisponible", "Oui", "Non", "Actualiser l'état", "Effacer la dernière erreur", "Copier le rapport de diagnostic", "Réessayer la configuration des alertes", "Réessayez la configuration des alertes après le combat.",
        "Afficher les outils expérimentaux", "Les commandes expérimentales sont volontairement vides pendant la phase 10. Les phases suivantes ajouteront ici des tests explicites de bordure, son, pistage et durée.",
        "Affiche les tests de développement facultatifs. Ils ne s'exécutent jamais simplement à l'ouverture de cet onglet.", "Opération inconnue",
        "Relit l'état actuel du combat, des auras, du son, du pistage et des actions bloquées.", "Oublie le dernier événement ADDON_ACTION_BLOCKED enregistré pendant cette session. Cela ne masque pas les erreurs Lua.", "Analyse à nouveau les améliorations actuelles et programme les alertes admissibles dix secondes avant expiration. Aucun son de test n'est joué.",
    },
    itIT = {
        "Diagnostica", "Prova gli effetti esistenti e crea un rapporto compatto per l'assistenza.",
        "Prova gli effetti esistenti e copia un rapporto compatto per l'assistenza. Aprire questa scheda non cambia le impostazioni di gioco.",
        "Laboratorio di prova", "Queste anteprime usano le icone di prova e il suono di avviso correnti dell'addon. Le verifiche sicure in combattimento saranno aggiunte nelle rispettive fasi.",
        "Stato del sistema", "Client", "Interfaccia", "Dati aura limitati", "Contenitori aura", "Stile nativo di dissoluzione", "Filtri aura tipizzati", "Suoni aura sicuri in combattimento", "API di tracciamento", "Ultima operazione bloccata",
        "Disponibile", "Non disponibile", "Sì", "No", "Aggiorna stato", "Cancella ultimo errore", "Copia rapporto diagnostico", "Riprova configurazione avvisi", "Riprova la configurazione degli avvisi dopo il combattimento.",
        "Mostra strumenti sperimentali", "I controlli sperimentali sono volutamente vuoti nella fase 10. Le fasi successive aggiungeranno qui verifiche esplicite per bordi, suoni, tracciamento e durata.",
        "Mostra verifiche di sviluppo facoltative. Non vengono mai eseguite solo aprendo questa scheda.", "Operazione sconosciuta",
        "Rilegge lo stato attuale di combattimento, aure, suoni, tracciamento e azioni bloccate.", "Dimentica l'ultimo evento ADDON_ACTION_BLOCKED registrato in questa sessione. Non nasconde gli errori Lua.", "Analizza nuovamente i benefici attuali e pianifica gli avvisi validi dieci secondi prima della scadenza. Non riproduce un suono di prova.",
    },
    ptBR = {
        "Diagnóstico", "Teste os efeitos existentes e gere um relatório compacto para o suporte.",
        "Teste os efeitos existentes e copie um relatório compacto para o suporte. Abrir esta aba não altera as configurações do jogo.",
        "Laboratório de testes", "Estas prévias usam os ícones de teste e o som de alerta atuais do addon. Testes seguros em combate serão adicionados em suas próprias fases.",
        "Status do sistema", "Cliente", "Interface", "Dados de aura restritos", "Contêineres de aura", "Estilo nativo de dissipação", "Filtros de aura tipados", "Sons de aura seguros em combate", "API de rastreamento", "Última operação bloqueada",
        "Disponível", "Indisponível", "Sim", "Não", "Atualizar status", "Limpar último erro", "Copiar relatório de diagnóstico", "Tentar configurar alertas novamente", "Tente configurar os alertas novamente após o combate.",
        "Mostrar ferramentas experimentais", "Os controles experimentais estão intencionalmente vazios na fase 10. Fases posteriores adicionarão aqui testes explícitos de borda, som, rastreamento e duração.",
        "Mostra testes de desenvolvimento opcionais. Eles nunca são executados apenas porque esta aba foi aberta.", "Operação desconhecida",
        "Lê novamente o estado atual de combate, auras, som, rastreamento e ações bloqueadas.", "Esquece o último evento ADDON_ACTION_BLOCKED registrado nesta sessão. Isso não oculta erros Lua.", "Verifica novamente os bônus atuais e agenda alertas válidos dez segundos antes de expirarem. Isso não toca um som de teste.",
    },
    ruRU = {
        "Диагностика", "Проверьте существующие эффекты и создайте краткий отчёт для поддержки.",
        "Проверьте существующие эффекты и скопируйте краткий отчёт для поддержки. Открытие этой вкладки не меняет игровые настройки.",
        "Лаборатория тестов", "Эти проверки используют текущие тестовые значки и звук оповещения аддона. Безопасные в бою проверки будут добавлены на отдельных этапах.",
        "Состояние системы", "Клиент", "Интерфейс", "Данные аур ограничены", "Контейнеры аур", "Стандартное оформление рассеивания", "Типизированные фильтры аур", "Безопасные в бою звуки аур", "API отслеживания", "Последняя заблокированная операция",
        "Доступно", "Недоступно", "Да", "Нет", "Обновить состояние", "Очистить последнюю ошибку", "Скопировать отчёт диагностики", "Повторить настройку оповещений", "Повторите настройку оповещений после боя.",
        "Показать экспериментальные инструменты", "Экспериментальные элементы на этапе 10 намеренно пусты. На следующих этапах здесь появятся отдельные проверки рамок, звуков, отслеживания и длительности.",
        "Показывает необязательные проверки для разработки. Они никогда не запускаются только из-за открытия этой вкладки.", "Неизвестная операция",
        "Повторно считывает текущее состояние боя, аур, звука, отслеживания и заблокированных действий.", "Забывает последнее событие ADDON_ACTION_BLOCKED, записанное в этом сеансе. Ошибки Lua при этом не скрываются.", "Повторно проверяет текущие положительные эффекты и планирует подходящие оповещения за десять секунд до окончания. Тестовый звук не воспроизводится.",
    },
    koKR = {
        "진단", "기존 효과를 시험하고 지원용 간단한 보고서를 만듭니다.",
        "기존 효과를 시험하고 지원용 간단한 보고서를 복사합니다. 이 탭을 여는 것만으로 게임 설정이 바뀌지 않습니다.",
        "테스트 연구실", "이 미리 보기는 애드온의 현재 테스트 아이콘과 알림 소리를 사용합니다. 전투 중 안전한 기능 검사는 각 단계에서 추가됩니다.",
        "시스템 상태", "클라이언트", "인터페이스", "오라 데이터 제한됨", "오라 컨테이너", "기본 해제 유형 표시", "유형별 오라 필터", "전투 중 안전한 오라 소리", "추적 API", "마지막으로 차단된 동작",
        "사용 가능", "사용 불가", "예", "아니요", "상태 새로 고침", "마지막 오류 지우기", "진단 보고서 복사", "알림 설정 다시 시도", "전투가 끝난 뒤 알림 설정을 다시 시도하세요.",
        "실험 도구 표시", "10단계에서는 실험용 조작부가 의도적으로 비어 있습니다. 이후 단계에서 테두리, 소리, 추적 및 지속시간 검사를 여기에 추가합니다.",
        "선택형 개발 검사를 표시합니다. 이 탭을 여는 것만으로 실행되지 않습니다.", "알 수 없는 동작",
        "현재 전투, 오라, 소리, 추적 및 차단된 동작 상태를 다시 읽습니다.", "이 세션에 기록된 마지막 ADDON_ACTION_BLOCKED 이벤트를 지웁니다. Lua 오류를 숨기지는 않습니다.", "현재 강화 효과를 다시 검사하고 만료 10초 전 알림을 예약합니다. 테스트 소리는 재생하지 않습니다.",
    },
    zhCN = {
        "诊断", "预览现有效果并生成简洁的支持报告。",
        "预览现有效果并复制简洁的支持报告。打开此标签页不会更改游戏设置。",
        "测试实验室", "这些预览使用插件当前的测试图标和提醒音效。战斗中安全的功能检测将在各自阶段加入。",
        "系统状态", "客户端", "界面", "光环数据受限", "光环容器", "原生驱散类型样式", "分类光环过滤器", "战斗中安全的光环音效", "追踪 API", "上次被阻止的操作",
        "可用", "不可用", "是", "否", "刷新状态", "清除上次错误", "复制诊断报告", "重试提醒设置", "请在战斗结束后重试提醒设置。",
        "显示实验工具", "第 10 阶段的实验控件特意留空。后续阶段将在此加入明确的边框、音效、追踪和持续时间检测。",
        "显示可选的开发检测。它们不会仅因打开此标签页而运行。", "未知操作",
        "重新读取当前的战斗、光环、音效、追踪和操作阻止状态。", "清除此会话中记录的上一个 ADDON_ACTION_BLOCKED 事件。这不会隐藏 Lua 错误。", "重新扫描当前增益，并为符合条件的增益安排到期前十秒提醒。此操作不会播放测试音效。",
    },
    zhTW = {
        "診斷", "預覽現有效果並產生精簡的支援報告。",
        "預覽現有效果並複製精簡的支援報告。開啟此分頁不會變更遊戲設定。",
        "測試實驗室", "這些預覽使用插件目前的測試圖示和提醒音效。戰鬥中安全的功能檢測將在各自階段加入。",
        "系統狀態", "用戶端", "介面", "光環資料受限", "光環容器", "原生驅散類型樣式", "分類光環篩選器", "戰鬥中安全的光環音效", "追蹤 API", "上次被阻止的操作",
        "可用", "不可用", "是", "否", "重新整理狀態", "清除上次錯誤", "複製診斷報告", "重試提醒設定", "請在戰鬥結束後重試提醒設定。",
        "顯示實驗工具", "第 10 階段的實驗控制項刻意留空。後續階段將在此加入明確的邊框、音效、追蹤和持續時間檢測。",
        "顯示選用的開發檢測。它們不會僅因開啟此分頁而執行。", "未知操作",
        "重新讀取目前的戰鬥、光環、音效、追蹤和操作阻止狀態。", "清除此工作階段中記錄的上一個 ADDON_ACTION_BLOCKED 事件。這不會隱藏 Lua 錯誤。", "重新掃描目前增益效果，並為符合條件的效果安排到期前十秒提醒。此操作不會播放測試音效。",
    },
}
diagnosticValues.esMX = diagnosticValues.esES
for locale, values in pairs(diagnosticValues) do
    for index, key in ipairs(diagnosticKeys) do translations[locale][key] = values[index] end
end

local awarenessKeys = {
    "Preview and opt into native debuff-type borders. These controls do not add sounds.", "Enable debuff borders", "Pulse borders",
    "Change debuff borders after combat.", "Border", "Border and icon", "Corner icon", "Debuff border style",
    "Cycle through Blizzard-native border, border-and-icon, and corner-icon presentations.", "Preview four types",
    "Preview debuff borders after combat.", "Debuff border preview shown.", "Debuff awareness", "Disabled", "Not tested",
    "Choose the Blizzard-native presentation used by live debuffs and the four-type preview.",
    "Preview Magic, Curse, Disease, and Poison using the selected border style and pulse setting.",
    "Preview",
}
local awarenessValues = {
    deDE = { "Native Debuff-Rahmen testen und aktivieren. Diese Optionen fügen keine Töne hinzu.", "Debuff-Rahmen aktivieren", "Rahmen pulsieren", "Ändere Debuff-Rahmen nach dem Kampf.", "Rahmen", "Rahmen und Symbol", "Ecksymbol", "Debuff-Rahmenstil", "Wechselt zwischen nativem Rahmen, Rahmen mit Symbol und Ecksymbol.", "Vier Typen testen", "Teste Debuff-Rahmen nach dem Kampf.", "Debuff-Rahmenvorschau angezeigt.", "Debuff-Erkennung", "Deaktiviert", "Nicht getestet", "Wähle die native Darstellung für Live-Debuffs und die Vier-Typen-Vorschau.", "Zeigt Magie, Fluch, Krankheit und Gift mit dem gewählten Rahmenstil und Pulsieren.", "Vorschau" },
    esES = { "Prueba y activa bordes nativos por tipo de perjuicio. Estos controles no añaden sonidos.", "Activar bordes de perjuicios", "Bordes pulsantes", "Cambia los bordes después del combate.", "Borde", "Borde e icono", "Icono de esquina", "Estilo de borde", "Alterna entre borde nativo, borde con icono e icono de esquina.", "Probar cuatro tipos", "Prueba los bordes después del combate.", "Vista previa de bordes mostrada.", "Detección de perjuicios", "Desactivado", "Sin probar", "Elige la presentación nativa usada por los perjuicios reales y la vista previa.", "Previsualiza Magia, Maldición, Enfermedad y Veneno con el estilo y pulso seleccionados.", "Vista previa" },
    frFR = { "Testez et activez les bordures natives par type d'affaiblissement. Aucun son n'est ajouté.", "Activer les bordures", "Bordures pulsées", "Modifiez les bordures après le combat.", "Bordure", "Bordure et icône", "Icône d'angle", "Style de bordure", "Parcourt les présentations natives : bordure, bordure et icône, ou icône d'angle.", "Tester quatre types", "Testez les bordures après le combat.", "Aperçu des bordures affiché.", "Détection des affaiblissements", "Désactivé", "Non testé", "Choisissez la présentation native des affaiblissements réels et de l'aperçu.", "Prévisualise Magie, Malédiction, Maladie et Poison avec le style et la pulsation choisis.", "Aperçu" },
    itIT = { "Prova e attiva i bordi nativi per tipo di penalità. Questi controlli non aggiungono suoni.", "Attiva bordi penalità", "Bordi pulsanti", "Modifica i bordi dopo il combattimento.", "Bordo", "Bordo e icona", "Icona angolare", "Stile bordo penalità", "Alterna bordo nativo, bordo con icona e icona angolare.", "Prova quattro tipi", "Prova i bordi dopo il combattimento.", "Anteprima bordi visualizzata.", "Rilevamento penalità", "Disattivato", "Non provato", "Scegli la presentazione nativa usata dalle penalità reali e dall'anteprima.", "Mostra Magia, Maledizione, Malattia e Veleno con stile e pulsazione selezionati.", "Anteprima" },
    ptBR = { "Teste e ative bordas nativas por tipo de penalidade. Estes controles não adicionam sons.", "Ativar bordas", "Bordas pulsantes", "Altere as bordas após o combate.", "Borda", "Borda e ícone", "Ícone de canto", "Estilo de borda", "Alterna entre borda nativa, borda com ícone e ícone de canto.", "Testar quatro tipos", "Teste as bordas após o combate.", "Prévia das bordas exibida.", "Detecção de penalidades", "Desativado", "Não testado", "Escolha a apresentação nativa usada pelas penalidades reais e pela prévia.", "Mostra Magia, Maldição, Doença e Veneno com o estilo e pulso selecionados.", "Prévia" },
    ruRU = { "Проверьте и включите стандартные рамки по типу отрицательного эффекта. Звуки не добавляются.", "Включить рамки", "Пульсация рамок", "Измените рамки после боя.", "Рамка", "Рамка и значок", "Угловой значок", "Стиль рамки", "Переключает стандартную рамку, рамку со значком и угловой значок.", "Проверить четыре типа", "Проверьте рамки после боя.", "Предпросмотр рамок показан.", "Распознавание эффектов", "Отключено", "Не проверено", "Выберите стандартное представление для настоящих эффектов и предпросмотра.", "Показывает магию, проклятие, болезнь и яд с выбранным стилем и пульсацией.", "Предпросмотр" },
    koKR = { "약화 효과 유형별 기본 테두리를 시험하고 사용합니다. 소리는 추가하지 않습니다.", "약화 효과 테두리 사용", "테두리 맥동", "전투가 끝난 뒤 테두리를 변경하세요.", "테두리", "테두리와 아이콘", "모서리 아이콘", "테두리 스타일", "기본 테두리, 테두리와 아이콘, 모서리 아이콘을 순환합니다.", "네 유형 미리 보기", "전투가 끝난 뒤 테두리를 미리 보세요.", "테두리 미리 보기를 표시했습니다.", "약화 효과 인식", "사용 안 함", "시험 안 함", "실제 약화 효과와 미리 보기에 사용할 기본 표시 방식을 선택합니다.", "선택한 스타일과 맥동으로 마법, 저주, 질병 및 독을 미리 봅니다.", "미리 보기" },
    zhCN = { "预览并启用原生减益类型边框。这些控件不会添加音效。", "启用减益边框", "边框脉动", "请在战斗结束后更改减益边框。", "边框", "边框和图标", "角落图标", "减益边框样式", "循环切换原生边框、边框和图标以及角落图标。", "预览四种类型", "请在战斗结束后预览减益边框。", "已显示减益边框预览。", "减益识别", "已禁用", "未测试", "选择用于实际减益和四类型预览的原生显示方式。", "使用所选边框样式和脉动预览魔法、诅咒、疾病和中毒。", "预览" },
    zhTW = { "預覽並啟用原生減益類型邊框。這些控制項不會加入音效。", "啟用減益邊框", "邊框脈動", "請在戰鬥結束後變更減益邊框。", "邊框", "邊框和圖示", "角落圖示", "減益邊框樣式", "循環切換原生邊框、邊框和圖示以及角落圖示。", "預覽四種類型", "請在戰鬥結束後預覽減益邊框。", "已顯示減益邊框預覽。", "減益識別", "已停用", "未測試", "選擇用於實際減益和四類型預覽的原生顯示方式。", "使用所選邊框樣式和脈動預覽魔法、詛咒、疾病和中毒。", "預覽" },
}
awarenessValues.esMX = awarenessValues.esES
for locale, values in pairs(awarenessValues) do
    for index, key in ipairs(awarenessKeys) do translations[locale][key] = values[index] end
end

local debuffSoundKeys = {
    "Debuff sounds", "registered", "learned", "seeded", "Pending combat", "Registration warning",
    "Enable learned debuff sounds", "Change debuff sounds after combat.", "Debuff sound", "Test sound",
    "Clear learned", "Clear learned debuffs after combat.", "Learned debuff data cleared.",
    "Preview debuff borders and configure exact-spell sound alerts learned outside combat.",
}
local debuffSoundValues = {
    deDE = { "Debuff-Töne", "registriert", "gelernt", "vorgegeben", "Wartet auf Kampfende", "Registrierungswarnung", "Gelernte Debuff-Töne aktivieren", "Ändere Debuff-Töne nach dem Kampf.", "Debuff-Ton", "Ton testen", "Gelernte löschen", "Lösche gelernte Debuffs nach dem Kampf.", "Gelernte Debuff-Daten gelöscht.", "Debuff-Rahmen testen und außerhalb des Kampfes gelernte, zauberspezifische Tonwarnungen konfigurieren." },
    esES = { "Sonidos de perjuicios", "registrados", "aprendidos", "predefinidos", "Pendiente de combate", "Aviso de registro", "Activar sonidos aprendidos", "Cambia los sonidos después del combate.", "Sonido de perjuicio", "Probar sonido", "Borrar aprendidos", "Borra los perjuicios aprendidos después del combate.", "Datos de perjuicios aprendidos borrados.", "Previsualiza bordes y configura alertas por hechizo aprendidas fuera de combate." },
    frFR = { "Sons d’affaiblissements", "enregistrés", "appris", "prédéfinis", "En attente du combat", "Avertissement d’enregistrement", "Activer les sons appris", "Modifiez les sons après le combat.", "Son d’affaiblissement", "Tester le son", "Effacer les appris", "Effacez les affaiblissements appris après le combat.", "Données apprises effacées.", "Prévisualisez les bordures et configurez les alertes par sort apprises hors combat." },
    itIT = { "Suoni penalità", "registrati", "appresi", "predefiniti", "In attesa del combattimento", "Avviso di registrazione", "Attiva suoni appresi", "Modifica i suoni dopo il combattimento.", "Suono penalità", "Prova suono", "Cancella appresi", "Cancella le penalità apprese dopo il combattimento.", "Dati appresi cancellati.", "Mostra i bordi e configura gli avvisi per incantesimo appresi fuori dal combattimento." },
    ptBR = { "Sons de penalidades", "registrados", "aprendidos", "predefinidos", "Pendente de combate", "Aviso de registro", "Ativar sons aprendidos", "Altere os sons após o combate.", "Som de penalidade", "Testar som", "Limpar aprendidos", "Limpe as penalidades aprendidas após o combate.", "Dados aprendidos removidos.", "Visualize as bordas e configure alertas por feitiço aprendidos fora de combate." },
    ruRU = { "Звуки отрицательных эффектов", "зарегистрировано", "изучено", "предустановлено", "Ожидание конца боя", "Предупреждение регистрации", "Включить звуки изученных эффектов", "Измените звуки после боя.", "Звук эффекта", "Проверить звук", "Очистить изученные", "Очистите изученные эффекты после боя.", "Данные изученных эффектов очищены.", "Проверьте рамки и настройте звуки заклинаний, изученных вне боя." },
    koKR = { "약화 효과 소리", "등록", "학습", "기본 제공", "전투 종료 대기", "등록 경고", "학습한 약화 효과 소리 사용", "전투가 끝난 뒤 소리를 변경하세요.", "약화 효과 소리", "소리 시험", "학습 목록 지우기", "전투가 끝난 뒤 학습 목록을 지우세요.", "학습한 약화 효과 데이터를 지웠습니다.", "테두리를 미리 보고 전투 밖에서 학습한 주문별 소리 알림을 설정합니다." },
    zhCN = { "减益音效", "已注册", "已学习", "预置", "等待战斗结束", "注册警告", "启用已学习的减益音效", "请在战斗结束后更改减益音效。", "减益音效", "测试音效", "清除已学习", "请在战斗结束后清除已学习减益。", "已清除学习的减益数据。", "预览减益边框并配置在非战斗状态学习的精确法术音效提醒。" },
    zhTW = { "減益音效", "已註冊", "已學習", "預設", "等待戰鬥結束", "註冊警告", "啟用已學習的減益音效", "請在戰鬥結束後變更減益音效。", "減益音效", "測試音效", "清除已學習", "請在戰鬥結束後清除已學習減益。", "已清除學習的減益資料。", "預覽減益邊框並設定在非戰鬥狀態學習的精確法術音效提醒。" },
}
debuffSoundValues.esMX = debuffSoundValues.esES
for locale, values in pairs(debuffSoundValues) do
    for index, key in ipairs(debuffSoundKeys) do translations[locale][key] = values[index] end
end

local debuffLibraryKeys = {
    "Debuff Library",
    "Search the build-matched debuff catalog. Use the check or X to add or remove a Personal Tracker.",
    "Search by name, type, or Spell ID",
    "No description is available from this client build.",
    "Add Personal Tracker", "Remove Personal Tracker",
    "%d debuffs · build %s", "Unknown", "Unknown source",
    "Personal tracker data is too large.", "Invalid Personal Tracker data.",
}
local debuffLibraryValues = {
    deDE = { "Debuff-Bibliothek", "Durchsuche den Debuff-Katalog dieses Builds. Mit Haken oder X fügst du einen persönlichen Tracker hinzu oder entfernst ihn.", "Nach Name, Typ oder Zauber-ID suchen", "Für diesen Client-Build ist keine Beschreibung verfügbar.", "Persönlichen Tracker hinzufügen", "Persönlichen Tracker entfernen", "%d Debuffs · Build %s", "Unbekannt", "Unbekannte Quelle", "Die Daten der persönlichen Tracker sind zu groß.", "Ungültige Daten für persönliche Tracker." },
    esES = { "Biblioteca de perjuicios", "Busca en el catálogo de perjuicios de esta versión. Usa la marca o la X para añadir o quitar un rastreador personal.", "Buscar por nombre, tipo o ID de hechizo", "No hay descripción disponible en esta versión del cliente.", "Añadir rastreador personal", "Quitar rastreador personal", "%d perjuicios · versión %s", "Desconocido", "Fuente desconocida", "Los datos de rastreadores personales son demasiado grandes.", "Datos de rastreadores personales no válidos." },
    frFR = { "Bibliothèque d’affaiblissements", "Recherchez dans le catalogue de cette version. Utilisez la coche ou le X pour ajouter ou retirer un suivi personnel.", "Rechercher par nom, type ou ID de sort", "Aucune description n’est disponible pour cette version du client.", "Ajouter un suivi personnel", "Retirer le suivi personnel", "%d affaiblissements · version %s", "Inconnu", "Source inconnue", "Les données de suivi personnel sont trop volumineuses.", "Données de suivi personnel non valides." },
    itIT = { "Libreria penalità", "Cerca nel catalogo delle penalità di questa build. Usa la spunta o la X per aggiungere o rimuovere un tracciamento personale.", "Cerca per nome, tipo o ID incantesimo", "Nessuna descrizione disponibile per questa build del client.", "Aggiungi tracciamento personale", "Rimuovi tracciamento personale", "%d penalità · build %s", "Sconosciuto", "Fonte sconosciuta", "I dati dei tracciamenti personali sono troppo grandi.", "Dati dei tracciamenti personali non validi." },
    ptBR = { "Biblioteca de penalidades", "Pesquise o catálogo de penalidades desta versão. Use a marca ou o X para adicionar ou remover um rastreador pessoal.", "Pesquisar por nome, tipo ou ID de feitiço", "Nenhuma descrição está disponível para esta versão do cliente.", "Adicionar rastreador pessoal", "Remover rastreador pessoal", "%d penalidades · versão %s", "Desconhecido", "Fonte desconhecida", "Os dados dos rastreadores pessoais são muito grandes.", "Dados de rastreadores pessoais inválidos." },
    ruRU = { "Библиотека отрицательных эффектов", "Поиск по каталогу отрицательных эффектов этой сборки. Нажмите галочку или X, чтобы добавить или удалить личное отслеживание.", "Поиск по названию, типу или ID заклинания", "Описание недоступно в этой сборке клиента.", "Добавить личное отслеживание", "Удалить личное отслеживание", "%d эффектов · сборка %s", "Неизвестно", "Неизвестный источник", "Данные личного отслеживания слишком велики.", "Недопустимые данные личного отслеживания." },
    koKR = { "약화 효과 목록", "이 빌드의 약화 효과 목록을 검색합니다. 체크 또는 X를 눌러 개인 추적을 추가하거나 제거하세요.", "이름, 유형 또는 주문 ID로 검색", "이 클라이언트 빌드에서 설명을 확인할 수 없습니다.", "개인 추적 추가", "개인 추적 제거", "약화 효과 %d개 · 빌드 %s", "알 수 없음", "알 수 없는 출처", "개인 추적 데이터가 너무 큽니다.", "개인 추적 데이터가 올바르지 않습니다." },
    zhCN = { "减益库", "搜索与此版本匹配的减益目录。使用勾选或 X 添加或移除个人追踪。", "按名称、类型或法术 ID 搜索", "此客户端版本没有可用的描述。", "添加个人追踪", "移除个人追踪", "%d 个减益 · 版本 %s", "未知", "未知来源", "个人追踪数据过大。", "个人追踪数据无效。" },
    zhTW = { "減益資料庫", "搜尋與此版本相符的減益目錄。使用勾選或 X 新增或移除個人追蹤。", "依名稱、類型或法術 ID 搜尋", "此用戶端版本沒有可用的說明。", "新增個人追蹤", "移除個人追蹤", "%d 個減益 · 版本 %s", "未知", "未知來源", "個人追蹤資料過大。", "個人追蹤資料無效。" },
}
debuffLibraryValues.esMX = debuffLibraryValues.esES
for locale, values in pairs(debuffLibraryValues) do
    for index, key in ipairs(debuffLibraryKeys) do translations[locale][key] = values[index] end
end

local buffRemovalKeys = {
    "The ten-second warning remains available outside combat. An optional native sound can play when a learned buff is removed, including during combat.",
    "Combat buff-removed sound",
    "Play a Blizzard-native sound when an eligible learned buff is removed. This works during combat but fires after the buff is gone, not ten seconds before.",
    "Change buff removal sounds after combat.",
    "Combat buff removal sounds",
    "Block specific buff spell IDs from triggering expiry or removal alerts.",
}
local buffRemovalValues = {
    deDE = { "Die Zehn-Sekunden-Warnung bleibt außerhalb des Kampfes verfügbar. Ein optionaler nativer Ton kann auch im Kampf abgespielt werden, wenn ein gelernter Stärkungszauber entfernt wird.", "Kampfton bei Buff-Ende", "Spielt einen nativen Blizzard-Ton, wenn ein geeigneter gelernter Stärkungszauber entfernt wird. Dies funktioniert im Kampf, aber erst nachdem der Effekt verschwunden ist, nicht zehn Sekunden vorher.", "Ändere Buff-Endtöne nach dem Kampf.", "Kampftöne bei Buff-Ende", "Blockiert bestimmte Buff-Zauber-IDs für Ablauf- und Entfernungshinweise." },
    esES = { "El aviso de diez segundos sigue disponible fuera de combate. Un sonido nativo opcional puede sonar cuando se elimina un beneficio aprendido, incluso en combate.", "Sonido al terminar beneficio", "Reproduce un sonido nativo de Blizzard cuando se elimina un beneficio aprendido apto. Funciona en combate, pero suena después de desaparecer, no diez segundos antes.", "Cambia los sonidos de fin de beneficio después del combate.", "Sonidos de fin de beneficio en combate", "Bloquea ID de hechizos de beneficio para alertas de caducidad o eliminación." },
    frFR = { "L’avertissement à dix secondes reste disponible hors combat. Un son natif facultatif peut être joué lorsqu’une amélioration apprise est retirée, y compris en combat.", "Son de fin d’amélioration", "Joue un son natif de Blizzard lorsqu’une amélioration apprise admissible est retirée. Cela fonctionne en combat, mais après sa disparition, pas dix secondes avant.", "Modifiez les sons de fin d’amélioration après le combat.", "Sons de fin d’amélioration en combat", "Bloque certains ID d’amélioration pour les alertes d’expiration ou de retrait." },
    itIT = { "L’avviso a dieci secondi resta disponibile fuori dal combattimento. Un suono nativo facoltativo può essere riprodotto quando un beneficio appreso viene rimosso, anche in combattimento.", "Suono fine beneficio", "Riproduce un suono nativo di Blizzard quando un beneficio appreso idoneo viene rimosso. Funziona in combattimento, ma dopo la scomparsa, non dieci secondi prima.", "Modifica i suoni di fine beneficio dopo il combattimento.", "Suoni di fine beneficio in combattimento", "Blocca specifici ID di benefici dagli avvisi di scadenza o rimozione." },
    ptBR = { "O aviso de dez segundos continua disponível fora de combate. Um som nativo opcional pode tocar quando um bônus aprendido for removido, inclusive em combate.", "Som ao remover bônus", "Toca um som nativo da Blizzard quando um bônus aprendido elegível é removido. Funciona em combate, mas toca depois que o efeito termina, não dez segundos antes.", "Altere os sons de remoção de bônus após o combate.", "Sons de remoção de bônus em combate", "Bloqueia IDs específicos de bônus nos alertas de expiração ou remoção." },
    ruRU = { "Предупреждение за десять секунд доступно вне боя. Дополнительный системный звук может проигрываться при снятии изученного положительного эффекта, в том числе в бою.", "Звук снятия эффекта в бою", "Проигрывает системный звук Blizzard при снятии подходящего изученного положительного эффекта. Работает в бою, но после исчезновения эффекта, а не за десять секунд.", "Измените звуки снятия эффектов после боя.", "Звуки снятия эффектов в бою", "Блокирует указанные ID положительных эффектов для предупреждений об окончании или снятии." },
    koKR = { "10초 전 알림은 비전투 중에 계속 사용할 수 있습니다. 학습한 강화 효과가 제거될 때 선택적인 기본 소리를 전투 중에도 재생할 수 있습니다.", "전투 중 강화 효과 제거 소리", "조건에 맞는 학습한 강화 효과가 제거되면 Blizzard 기본 소리를 재생합니다. 전투 중에도 작동하지만 10초 전이 아니라 효과가 사라진 뒤에 재생됩니다.", "전투가 끝난 뒤 강화 효과 제거 소리를 변경하세요.", "전투 중 강화 효과 제거 소리", "특정 강화 효과 주문 ID를 만료 또는 제거 알림에서 제외합니다." },
    zhCN = { "十秒预警仍可在非战斗状态使用。已学习的增益被移除时，可选择播放原生音效，战斗中也有效。", "战斗中增益移除音效", "符合条件的已学习增益被移除时播放 Blizzard 原生音效。战斗中有效，但会在增益消失后播放，而不是提前十秒。", "请在战斗结束后更改增益移除音效。", "战斗中增益移除音效", "阻止指定增益法术 ID 触发到期或移除提醒。" },
    zhTW = { "十秒預警仍可在非戰鬥狀態使用。已學習的增益被移除時，可選擇播放原生音效，戰鬥中也有效。", "戰鬥中增益移除音效", "符合條件的已學習增益被移除時播放 Blizzard 原生音效。戰鬥中有效，但會在增益消失後播放，而不是提前十秒。", "請在戰鬥結束後變更增益移除音效。", "戰鬥中增益移除音效", "阻止指定增益法術 ID 觸發到期或移除提醒。" },
}
buffRemovalValues.esMX = buffRemovalValues.esES
for locale, values in pairs(buffRemovalValues) do
    for index, key in ipairs(buffRemovalKeys) do translations[locale][key] = values[index] end
end

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
