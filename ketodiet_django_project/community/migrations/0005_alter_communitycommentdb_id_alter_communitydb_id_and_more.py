# Generated by Django 4.1.7 on 2023-04-18 01:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('community', '0004_categorydb_remove_communitycommentdb_comment_count'),
    ]

    operations = [
        migrations.AlterField(
            model_name='communitycommentdb',
            name='id',
            field=models.IntegerField(max_length=30),
        ),
        migrations.AlterField(
            model_name='communitydb',
            name='id',
            field=models.IntegerField(max_length=30),
        ),
        migrations.AlterField(
            model_name='communitydb',
            name='recommend',
            field=models.CharField(max_length=2000),
        ),
    ]