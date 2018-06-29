ip = open("ipaddr", "r")
names = open("mchnames", "r")
lines = 0
for each in eachline(ip)
	lines = lines+1
end
seekstart(ip)
seekstart(names)
for i = 1:lines
	m_ip = strip(readuntil(ip, '\n'))
	print(m_ip, "\t")
	m_name = strip(readuntil(names, '\n'))
	println(m_name)
end

