FROM python:3.12-slim

WORKDIR /catty-reminders-app

# Копируем и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь оставшийся код
COPY . .

EXPOSE 8181

# Запускаем приложение
CMD["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8181"]