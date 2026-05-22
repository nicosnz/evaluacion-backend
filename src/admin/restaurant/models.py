from django.db import models
import uuid
from django.core.validators import MinValueValidator
from decimal import Decimal
from django.core.exceptions import ValidationError
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
    name=models.CharField(max_length=120,db_column="name",null=False)
    description=models.TextField(db_column="description",blank=True)
    address=models.CharField(max_length=255,db_column="address",null=False)
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."restaurant"'
        verbose_name="Restaurante"
        verbose_name_plural="Restaurantes"
        
class TableType(UUIDMixin,TimeStampedMixin):
    TYPE_TABLES=[
        ("shared","Shared"),
        ("private","Private"),
        ("vip","Vip"),
        ("outdoor","Outdoor"),
        ("bar","Bar")
    ]
    resturant=models.ForeignKey("Restaurant",on_delete=models.CASCADE,db_column="restaurant_id")
    name=models.CharField(max_length=100,db_column="name")
    type=models.CharField(max_length=50,db_column="type",choices=TYPE_TABLES)
    price=models.DecimalField(max_digits=10,decimal_places=2,validators=[MinValueValidator(Decimal("0.00"))],db_column="price")
    capacity=models.IntegerField(validators=[MinValueValidator(1)],db_column="capacity")
    description=models.TextField(db_column="description",blank=True)
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."table_type"'
        verbose_name="Tipo de mesa"
        verbose_name_plural="Tipos de mesa"
        
class Menu(UUIDMixin,TimeStampedMixin):
    resturant=models.ForeignKey("Restaurant",on_delete=models.CASCADE,db_column="restaurant_id")
    name=models.CharField(max_length=120,db_column="name")
    description=models.TextField(db_column="description",blank=True)
    courses_count=models.IntegerField(validators=[MinValueValidator(1)],db_column="courses_count")
    active_from=models.DateField(db_column="active_from")
    active_to=models.DateField(db_column="active_to")
    
    def clean(self):
        if self.active_to < self.active_from:
            raise ValidationError(
                "active_to debe ser mayor o igual a active_from"
            )
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."menu"'
        verbose_name="Menu"
        verbose_name_plural="Menus"

class MenuItem(UUIDMixin,TimeStampedMixin):
    menu=models.ForeignKey("Menu",on_delete=models.CASCADE,db_column="menu_id")
    name=models.CharField(max_length=120,db_column="name")
    description=models.TextField(db_column="description",blank=True)
    course_number=models.PositiveIntegerField(db_column="course_number")
    ingredients=models.TextField(db_column="ingredients")
    price=models.DecimalField(max_digits=10,decimal_places=2,validators=[MinValueValidator(Decimal("0.00"))],db_column="price")

    
    
    def __str__(self):
        return self.name
    class Meta:
        managed=False
        db_table='"content"."menu_item"'
        verbose_name="Item Menu"
        verbose_name_plural="Items Menu"
        
class Reservation(UUIDMixin,TimeStampedMixin):
    STATUS_RESERVATION=[
        ("pending","Pending"),
        ("confirmed","Confirmed"),
        ("cancelled","Cancelled"),
        ("completed","Completed")
    ]
    resturant=models.ForeignKey("Restaurant",on_delete=models.CASCADE,db_column="restaurant_id")
    table_type=models.ForeignKey("TableType",on_delete=models.CASCADE,db_column="table_type_id")
    reservation_time=models.DateTimeField(db_column="reservation_time")
    status=models.TextField(db_column="status",choices=STATUS_RESERVATION)
    
    def __str__(self):
        return self.status
    class Meta:
        managed=False
        db_table='"content"."reservation"'
        verbose_name="Reserva"
        verbose_name_plural="Reservaciones"
        
class ReservationGuests(UUIDMixin,TimeStampedMixin):
    reservation=models.ForeignKey("Reservation",on_delete=models.CASCADE,db_column="reservation_id")
    full_name=models.CharField(max_length=120,db_column="full_name")
    email=models.EmailField(max_length=255,db_column="email",null=True)
    phone=models.TextField(db_column="phone")
    
    
    
    def __str__(self):
        return self.full_name
    class Meta:
        managed=False
        db_table='"content"."reservation_guest"'
        verbose_name="Reserva Invitado"
        verbose_name_plural="Reserva Invitados"