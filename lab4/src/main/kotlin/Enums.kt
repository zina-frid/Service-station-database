import org.postgresql.util.PGobject

class PGEnum<T : Enum<T>>(enumTypeName: String, enumValue: T?) : PGobject() {
    init {
        value = enumValue?.name
        type = enumTypeName
    }
}

enum class BODY {
    Седан, Хэтчбек, Пикап, Микро, Кроссовер, Внедорожник, Кабриолет, Суперкар, Фургон, Купе, Грузовик, Минивен
}

enum class TRANSMISSION_TYPE {
    Механическая, Автоматическая, Полуавтоматическая
}

enum class MAINTENANCE_TYPE {
    Плановое, Аварийное
}

enum class REQUEST_STATUS {
    Поступило, В_работе, Ожидает, Готово, Завершено
}