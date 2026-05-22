from django.db import models
import uuid
# Create your models here.
class TimeStampedMixin(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        abstract = True

class UUIDMixin(models.Model):
    id=models.UUIDField(primary_key=True,default=uuid.uuid4,editable=False)
    
    class Meta:
        abstract=True

class Restaurant(UUIDMixin,TimeStampedMixin):
    name=models.TextField(db_column="name")
    description=models.TextField(db_column="description")
    address=models.TextField(db_column="address")
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."restaurant"'
        verbose_name="Restaurante"
        verbose_name_plural="Restaurantes"
        
class TableType(UUIDMixin,TimeStampedMixin):
    resturant=models.ForeignKey("Restaurant",on_delete=models.CASCADE,db_column="restaurant_id")
    name=models.TextField(db_column="name")
    type=models.TextField(db_column="type")
    price=models.FloatField(db_column="price")
    capacity=models.IntegerField(db_column="capacity")
    description=models.TextField(db_column="description")
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."table_type"'
        verbose_name="Tipo de mesa"
        verbose_name_plural="Tipos de mesa"
        
class Menu(UUIDMixin,TimeStampedMixin):
    resturant=models.ForeignKey("Restaurant",on_delete=models.CASCADE,db_column="restaurant_id")
    name=models.TextField(db_column="name")
    description=models.TextField(db_column="description")
    courses_count=models.IntegerField(db_column="courses_count")
    active_from=models.DateField(db_column="active_from")
    active_to=models.DateField(db_column="active_to")
    
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."menu"'
        verbose_name="Menu"
        verbose_name_plural="Menus"

class MenuItem(UUIDMixin,TimeStampedMixin):
    menu=models.ForeignKey("Menu",on_delete=models.CASCADE,db_column="menu_id")
    name=models.TextField(db_column="name")
    description=models.TextField(db_column="description")
    course_number=models.IntegerField(db_column="course_number")
    description=models.TextField(db_column="ingredients")
    
    
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."menu_item"'
        verbose_name="Item Menu"
        verbose_name_plural="Items Menu"
        
class Reservation(UUIDMixin,TimeStampedMixin):
    resturant=models.ForeignKey("Restaurant",on_delete=models.CASCADE,db_column="restaurant_id")
    table_type=models.ForeignKey("TableType",on_delete=models.CASCADE,db_column="table_type_id")
    reservation_time=models.DateTimeField(db_column="reservation_time")
    status=models.TextField(db_column="status")
    
    
    
    def __str__(self):
        return self.status
    class Meta:
        managed=False
        db_table='"content"."reservation"'
        verbose_name="Reserva"
        verbose_name_plural="Reservaciones"
        
class ReservationGuests(UUIDMixin,TimeStampedMixin):
    reservation=models.ForeignKey("Reservation",on_delete=models.CASCADE,db_column="reservation_id")
    full_name=models.TextField(db_column="full_name")
    email=models.TextField(db_column="email")
    phone=models.TextField(db_column="phone")
    
    
    
    def __str__(self):
        return self.full_name
    class Meta:
        managed=False
        db_table='"content"."reservation_guest"'
        verbose_name="Reserva Invitado"
        verbose_name_plural="Reserva Invitados"