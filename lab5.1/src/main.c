extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);

void display_clear()
{
	int i;
	for(i=1; i<=8; i++)
	{
		max7219_send(i, 0xF);
	}
}

void display(int data, int num_digs)
{
	int i;
	for(i=1; i<=num_digs; i++)
	{
		max7219_send(i, data%10);
		data/=10;
	}
}

int main()
{
	int student_id = 713407;
    GPIO_init();
    max7219_init();
    display_clear();
    display(student_id, 7);
    return 0;
}
