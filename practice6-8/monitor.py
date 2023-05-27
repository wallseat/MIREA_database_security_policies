import psutil
import time

MEMORY_THRESHOLD = 80.0
CPU_THRESHOLD = 80.0
DISK_THRESHOLD = 80.0

while True:
    # мониторинг использования ресурсов процесса Postgres
    for proc in psutil.process_iter(["pid", "name", "cpu_percent", "memory_percent"]):
        if proc.info["name"] == "postgres":
            pid = proc.info["pid"]
            cpu_percent = proc.info["cpu_percent"]
            mem_percent = proc.info["memory_percent"]
            mem_info = proc.memory_info()
            rss = mem_info.rss / (1024 * 1024)  # в мегабайтах
            vms = mem_info.vms / (1024 * 1024)  # в мегабайтах
            print(
                f"Postgres process (PID {pid}): CPU usage: {cpu_percent}%, "
                f"memory usage: {mem_percent}% ({rss:.2f} MB RSS, {vms:.2f} MB VMS)"
            )

            if mem_percent > MEMORY_THRESHOLD:
                print(
                    f"Postgres process (PID {pid}) "
                    f"is using too much memory: {mem_percent}%"
                )

            if cpu_percent > CPU_THRESHOLD:
                print(
                    f"Postgres process (PID {pid}) "
                    f"is using too much CPU: {cpu_percent}%",
                    color="yellow",
                )

    cpu_percent = psutil.cpu_percent()
    mem = psutil.virtual_memory()
    mem_percent = mem.percent
    mem_used = mem.used / (1024 * 1024 * 1024)  # в гигабайтах
    disk = psutil.disk_usage("/")
    disk_percent = disk.percent
    disk_used = disk.used / (1024 * 1024 * 1024)  # в гигабайтах
    print(
        f"System usage: CPU usage: {cpu_percent}%, "
        f"memory usage: {mem_percent}% ({mem_used:.2f} GB used), "
        f"disk usage: {disk_percent}% ({disk_used:.2f} GB used)"
    )

    if mem_percent > MEMORY_THRESHOLD:
        print(f"System is using too much memory: {mem_percent}%")

    if cpu_percent > CPU_THRESHOLD:
        print(f"System is using too much CPU: {cpu_percent}%")

    if disk_percent > DISK_THRESHOLD:
        print(f"System is using too much disk: {disk_percent}%")

    time.sleep(60)
