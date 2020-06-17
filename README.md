<p align="center">
	<img width="130px;" src="https://raw.githubusercontent.com/iwillenshofer/resources/main/images/42_logo_black.svg" align="center" alt="42" />&nbsp;&nbsp;&nbsp;
	<img width="130px" src="https://raw.githubusercontent.com/iwillenshofer/resources/main/achievements/ft_services.png" align="center" alt="ft_services" />
	<h1 align="center">ft_services</h1>
</p>
<p align="center">
	<img src="https://img.shields.io/badge/Success-100/100_✓-gray.svg?colorA=61c265&colorB=4CAF50&style=for-the-badge">
	<img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black">

</p>

<p align="center">
	<b><i>Development repository for the 42cursus ft_services project @ 42 São Paulo</i></b><br>
</p>

<p align="center">
	<img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/iwillenshofer/ft_services?color=blueviolet" />
	<img alt="GitHub top language" src="https://img.shields.io/github/languages/top/iwillenshofer/ft_services?color=blue" />
	<img alt="GitHub top language" src="https://img.shields.io/github/commit-activity/t/iwillenshofer/ft_services?color=brightgreen" />
	<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/iwillenshofer/ft_services?color=brightgreen" />
</p>
<br>

> _This project consist to clusturing an docker-compose application and deploy
it with Kubernetes.
_



<br>

<p align="center">
	<table>
		<tr>
			<td><b>Est. Time</b></td>
			<td><b>Skills</b></td>
			<td><b>Difficulty</b></td>
		</tr>
		<tr>
			<td valign="top">210 hours</td>
			<td valign="top">
<img src="https://img.shields.io/badge/Network & system administration-555">
<img src="https://img.shields.io/badge/Rigor-555">
			</td>
			<td valign="top"> 10042 XP</td>
		</tr>
	</table>
</p>

<br>

### Environment
This project was developed in a VirtualBox environment running Ubuntu Linux 20.04.
Before launching the setup script, the following dependencies must be satisfied:
The following prerequisites must be installed:
```
Docker
minikube
kubectl
```

### Usage
```bash
$ ./setup.sh
```

### Services

` ports 80 and 443 ` **NGINX**:
Cluster main web server, acting as a reverse proxy to the other containers.

` port 3306 ` **MySQL**
Relational database to handle data needs for the Wordpress content website.

` port 5050 ` **Wordpress**
Cluster content management system.

` port 5000 ` **PHPMyAdmin**
Database management system, with graphical user interface.

` port 3000 ` **Grafana**
Metrics visualization tool with dashboards.

` port 21 ` **FTPS Server**
Simple and secure FTP service with SSL security availability, connected to the mounting point on the Wordpress data directory.

` port 8086 ` **InfluxDB**
Time-series database system, which stores cluster metrics data to be available to the Grafana pod as a visualization tool.
